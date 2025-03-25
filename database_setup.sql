-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  user_role TEXT NOT NULL CHECK (user_role IN ('student', 'admin', 'supervisor', 'labor')),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone_number TEXT,
  profile_image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE
);

-- Create housing_units table
CREATE TABLE IF NOT EXISTS housing_units (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  building_name TEXT NOT NULL,
  room_number TEXT NOT NULL,
  capacity INTEGER NOT NULL,
  floor_number INTEGER NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  monthly_rate DECIMAL(10,2) NOT NULL,
  unit_type TEXT NOT NULL,
  amenities JSONB,
  UNIQUE(building_name, room_number)
);

-- Create student_profiles table
CREATE TABLE IF NOT EXISTS student_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  student_id TEXT UNIQUE NOT NULL,
  housing_unit_id UUID REFERENCES housing_units(id),
  enrollment_date DATE NOT NULL,
  academic_year INTEGER NOT NULL,
  program TEXT NOT NULL,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  outstanding_balance DECIMAL(10,2) DEFAULT 0.00,
  check_in_date DATE,
  expected_check_out_date DATE
);

-- Create attendance_records table
CREATE TABLE IF NOT EXISTS attendance_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  student_id UUID NOT NULL REFERENCES student_profiles(id),
  recorded_by UUID REFERENCES users(id),
  check_in_time TIMESTAMP WITH TIME ZONE NOT NULL,
  attendance_type TEXT NOT NULL CHECK (attendance_type IN ('regular', 'event', 'curfew')),
  location TEXT,
  notes TEXT
);

-- Create vacation_requests table
CREATE TABLE IF NOT EXISTS vacation_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  student_id UUID NOT NULL REFERENCES student_profiles(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES users(id),
  approval_date TIMESTAMP WITH TIME ZONE,
  notes TEXT
);

-- Create eviction_requests table
CREATE TABLE IF NOT EXISTS eviction_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  student_id UUID NOT NULL REFERENCES student_profiles(id),
  requested_move_out_date DATE NOT NULL,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES users(id),
  approval_date TIMESTAMP WITH TIME ZONE,
  actual_move_out_date DATE,
  condition_check_completed BOOLEAN DEFAULT FALSE,
  notes TEXT
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  student_id UUID NOT NULL REFERENCES student_profiles(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  payment_method TEXT NOT NULL,
  payment_status TEXT NOT NULL DEFAULT 'completed' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_type TEXT NOT NULL CHECK (payment_type IN ('rent', 'deposit', 'penalty', 'other')),
  reference_number TEXT,
  transaction_details JSONB,
  notes TEXT
);

-- Create cleaning_tasks table
CREATE TABLE IF NOT EXISTS cleaning_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  housing_unit_id UUID REFERENCES housing_units(id),
  assigned_to UUID REFERENCES users(id),
  assigned_by UUID REFERENCES users(id),
  due_date DATE NOT NULL,
  task_description TEXT NOT NULL,
  priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  completed_at TIMESTAMP WITH TIME ZONE,
  verification_notes TEXT,
  verified_by UUID REFERENCES users(id)
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  related_entity_id UUID,
  related_entity_type TEXT
);

-- Insert sample data for testing
-- Sample housing units
INSERT INTO housing_units (building_name, room_number, capacity, floor_number, monthly_rate, unit_type, amenities)
VALUES
  ('West Hall', '101', 2, 1, 500.00, 'double', '{"air_conditioning": true, "private_bathroom": false}'),
  ('West Hall', '102', 2, 1, 500.00, 'double', '{"air_conditioning": true, "private_bathroom": false}'),
  ('East Hall', '201', 1, 2, 700.00, 'single', '{"air_conditioning": true, "private_bathroom": true}'),
  ('South Hall', '301', 4, 3, 400.00, 'quad', '{"air_conditioning": false, "private_bathroom": false}');

-- Sample user roles
INSERT INTO users (email, password, user_role, first_name, last_name, phone_number)
VALUES
  ('admin@university.edu', 'hashed_password', 'admin', 'Admin', 'User', '123-456-7890'),
  ('supervisor@university.edu', 'hashed_password', 'supervisor', 'Super', 'Visor', '123-456-7891'),
  ('labor@university.edu', 'hashed_password', 'labor', 'Labor', 'Staff', '123-456-7892'),
  ('student1@university.edu', 'hashed_password', 'student', 'John', 'Doe', '123-456-7893'),
  ('student2@university.edu', 'hashed_password', 'student', 'Jane', 'Smith', '123-456-7894');

-- Sample student profiles
INSERT INTO student_profiles (user_id, student_id, housing_unit_id, enrollment_date, academic_year, program)
VALUES
  ((SELECT id FROM users WHERE email = 'student1@university.edu'), 'S12345', 
   (SELECT id FROM housing_units WHERE building_name = 'West Hall' AND room_number = '101'),
   '2023-09-01', 2, 'Computer Science'),
  ((SELECT id FROM users WHERE email = 'student2@university.edu'), 'S12346', 
   (SELECT id FROM housing_units WHERE building_name = 'East Hall' AND room_number = '201'),
   '2023-09-01', 3, 'Business Administration');

-- Create Row Level Security (RLS) policies
-- Enable RLS on tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE housing_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE vacation_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE eviction_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE cleaning_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Example policies (you would customize these based on your security requirements)
-- Users table policy
CREATE POLICY users_policy ON users
  USING (auth.uid() = id OR 
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_role IN ('admin', 'supervisor')));

-- Notifications policy - users can only see their own notifications
CREATE POLICY notifications_policy ON notifications
  USING (user_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND user_role = 'admin'));

-- Create database functions for common operations
-- Function to record attendance
CREATE OR REPLACE FUNCTION record_attendance(
  p_student_id UUID,
  p_recorder_id UUID,
  p_attendance_type TEXT,
  p_location TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  new_id UUID;
BEGIN
  INSERT INTO attendance_records (
    student_id, 
    recorded_by, 
    check_in_time, 
    attendance_type, 
    location, 
    notes
  ) VALUES (
    p_student_id,
    p_recorder_id,
    NOW(),
    p_attendance_type,
    p_location,
    p_notes
  ) RETURNING id INTO new_id;
  
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Function to process payment
CREATE OR REPLACE FUNCTION process_payment(
  p_student_id UUID,
  p_amount DECIMAL,
  p_payment_method TEXT,
  p_payment_type TEXT,
  p_reference_number TEXT DEFAULT NULL,
  p_transaction_details JSONB DEFAULT NULL,
  p_notes TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  new_payment_id UUID;
BEGIN
  -- Insert new payment
  INSERT INTO payments (
    student_id,
    amount,
    payment_method,
    payment_type,
    reference_number,
    transaction_details,
    notes
  ) VALUES (
    p_student_id,
    p_amount,
    p_payment_method,
    p_payment_type,
    p_reference_number,
    p_transaction_details,
    p_notes
  ) RETURNING id INTO new_payment_id;
  
  -- Update student balance
  UPDATE student_profiles
  SET outstanding_balance = outstanding_balance - p_amount
  WHERE id = p_student_id;
  
  -- Create notification
  INSERT INTO notifications (
    user_id,
    title,
    message,
    notification_type,
    related_entity_id,
    related_entity_type
  ) VALUES (
    (SELECT user_id FROM student_profiles WHERE id = p_student_id),
    'Payment Processed',
    'Your payment of $' || p_amount || ' has been processed.',
    'payment',
    new_payment_id,
    'payment'
  );
  
  RETURN new_payment_id;
END;
$$ LANGUAGE plpgsql;

-- Create database triggers
-- Trigger to notify when vacation request status changes
CREATE OR REPLACE FUNCTION notify_vacation_request_update() RETURNS TRIGGER AS $$
BEGIN
  -- If status changed to approved or rejected
  IF NEW.status <> OLD.status AND (NEW.status = 'approved' OR NEW.status = 'rejected') THEN
    INSERT INTO notifications (
      user_id,
      title,
      message,
      notification_type,
      related_entity_id,
      related_entity_type
    ) VALUES (
      (SELECT user_id FROM student_profiles WHERE id = NEW.student_id),
      'Vacation Request ' || INITCAP(NEW.status),
      'Your vacation request from ' || NEW.start_date || ' to ' || NEW.end_date || ' has been ' || NEW.status || '.',
      'vacation_request',
      NEW.id,
      'vacation_request'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vacation_request_status_change_trigger
  AFTER UPDATE OF status ON vacation_requests
  FOR EACH ROW
  EXECUTE FUNCTION notify_vacation_request_update();

-- Trigger to notify when eviction request status changes
CREATE OR REPLACE FUNCTION notify_eviction_request_update() RETURNS TRIGGER AS $$
BEGIN
  -- If status changed to approved or rejected
  IF NEW.status <> OLD.status AND (NEW.status = 'approved' OR NEW.status = 'rejected') THEN
    INSERT INTO notifications (
      user_id,
      title,
      message,
      notification_type,
      related_entity_id,
      related_entity_type
    ) VALUES (
      (SELECT user_id FROM student_profiles WHERE id = NEW.student_id),
      'Eviction Request ' || INITCAP(NEW.status),
      'Your eviction request for ' || NEW.requested_move_out_date || ' has been ' || NEW.status || '.',
      'eviction_request',
      NEW.id,
      'eviction_request'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER eviction_request_status_change_trigger
  AFTER UPDATE OF status ON eviction_requests
  FOR EACH ROW
  EXECUTE FUNCTION notify_eviction_request_update(); 