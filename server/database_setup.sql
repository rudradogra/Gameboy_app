-- GameBoy Dating App Database Schema
-- Run these commands in your Supabase SQL editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

-- Create indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  age INTEGER NOT NULL CHECK (age >= 18 AND age <= 100),
  bio TEXT DEFAULT '',
  interests TEXT[] DEFAULT '{}',
  location VARCHAR(255) DEFAULT '',
  image_urls TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for profiles table
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_is_active ON profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_profiles_age ON profiles(age);

-- Matches table
CREATE TABLE IF NOT EXISTS matches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user1_action VARCHAR(20) NOT NULL CHECK (user1_action IN ('like', 'superlike', 'pass')),
  user2_action VARCHAR(20) CHECK (user2_action IN ('like', 'superlike', 'pass')),
  is_mutual BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
);

-- Create indexes for matches table
CREATE INDEX IF NOT EXISTS idx_matches_user1_id ON matches(user1_id);
CREATE INDEX IF NOT EXISTS idx_matches_user2_id ON matches(user2_id);
CREATE INDEX IF NOT EXISTS idx_matches_is_mutual ON matches(is_mutual);
CREATE INDEX IF NOT EXISTS idx_matches_created_at ON matches(created_at);

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Profiles policies
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (is_active = true);
CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own profile" ON profiles FOR DELETE USING (auth.uid() = user_id);

-- Matches policies
CREATE POLICY "Users can view their own matches" ON matches FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);
CREATE POLICY "Users can create matches" ON matches FOR INSERT WITH CHECK (auth.uid() = user1_id);
CREATE POLICY "Users can update their own matches" ON matches FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);
CREATE POLICY "Users can delete their own matches" ON matches FOR DELETE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Create storage bucket for profile images (run this in the Supabase dashboard)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('profile-images', 'profile-images', true);

-- Storage policies for profile images
-- CREATE POLICY "Profile images are publicly accessible" ON storage.objects FOR SELECT USING (bucket_id = 'profile-images');
-- CREATE POLICY "Users can upload their own profile images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
-- CREATE POLICY "Users can update their own profile images" ON storage.objects FOR UPDATE USING (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
-- CREATE POLICY "Users can delete their own profile images" ON storage.objects FOR DELETE USING (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
