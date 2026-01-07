-- Supabase Database Schema for FitSync/GymExplore
-- Run this in your Supabase SQL Editor to create all necessary tables

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    email TEXT UNIQUE,
    phone TEXT,
    profile_image TEXT,
    age INTEGER CHECK (age > 0 AND age < 150),
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    height DECIMAL(5,2), -- in cm
    weight DECIMAL(5,2), -- in kg
    target_weight DECIMAL(5,2),
    goal TEXT CHECK (goal IN ('weight_loss', 'muscle_gain', 'maintain', 'general_fitness')),
    activity_level TEXT CHECK (activity_level IN ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active')),
    city TEXT,
    gym_id UUID REFERENCES public.gyms(id) ON DELETE SET NULL,
    is_guest BOOLEAN DEFAULT true,
    is_premium BOOLEAN DEFAULT false,
    premium_expiry_date TIMESTAMPTZ,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own data
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================
-- GYMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.gyms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT DEFAULT 'India',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone TEXT,
    email TEXT,
    website TEXT,
    image_url TEXT,
    gallery_urls TEXT[],
    amenities TEXT[],
    opening_hours JSONB,
    monthly_fee DECIMAL(10, 2),
    annual_fee DECIMAL(10, 2),
    has_personal_training BOOLEAN DEFAULT false,
    has_group_classes BOOLEAN DEFAULT false,
    rating DECIMAL(2, 1) CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for gyms (public read, admin write)
ALTER TABLE public.gyms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view gyms" ON public.gyms
    FOR SELECT USING (true);

-- ============================================
-- WORKOUTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    workout_name TEXT NOT NULL,
    workout_type TEXT CHECK (workout_type IN ('strength', 'cardio', 'flexibility', 'hiit', 'mixed')),
    exercises JSONB NOT NULL DEFAULT '[]'::jsonb,
    duration INTEGER NOT NULL, -- in minutes
    calories_burned INTEGER,
    logged_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_workouts_user_id ON public.workouts(user_id);
CREATE INDEX idx_workouts_logged_at ON public.workouts(logged_at DESC);

-- Enable RLS
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own workouts" ON public.workouts
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workouts" ON public.workouts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workouts" ON public.workouts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workouts" ON public.workouts
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- MEALS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.meals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    total_calories INTEGER NOT NULL DEFAULT 0,
    total_protein DECIMAL(6, 2) DEFAULT 0,
    total_carbs DECIMAL(6, 2) DEFAULT 0,
    total_fat DECIMAL(6, 2) DEFAULT 0,
    logged_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_meals_user_id ON public.meals(user_id);
CREATE INDEX idx_meals_logged_at ON public.meals(logged_at DESC);

-- Enable RLS
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meals" ON public.meals
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meals" ON public.meals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meals" ON public.meals
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meals" ON public.meals
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- CHALLENGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    challenge_type TEXT CHECK (challenge_type IN ('workout', 'steps', 'calories', 'streak', 'custom')),
    target_value DECIMAL(10, 2),
    target_unit TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    image_url TEXT,
    reward_points INTEGER DEFAULT 0,
    participant_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active challenges" ON public.challenges
    FOR SELECT USING (is_active = true);

-- ============================================
-- CHALLENGE PARTICIPANTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.challenge_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    progress DECIMAL(5, 2) DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    is_completed BOOLEAN DEFAULT false,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    UNIQUE(challenge_id, user_id)
);

-- Indexes
CREATE INDEX idx_challenge_participants_user ON public.challenge_participants(user_id);
CREATE INDEX idx_challenge_participants_challenge ON public.challenge_participants(challenge_id);

-- Enable RLS
ALTER TABLE public.challenge_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own participation" ON public.challenge_participants
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view challenge leaderboard" ON public.challenge_participants
    FOR SELECT USING (true);

CREATE POLICY "Users can join challenges" ON public.challenge_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress" ON public.challenge_participants
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can leave challenges" ON public.challenge_participants
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- EXERCISES REFERENCE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    body_part TEXT,
    equipment TEXT,
    category TEXT CHECK (category IN ('strength', 'cardio', 'flexibility', 'plyometric')),
    difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    instructions TEXT[],
    video_url TEXT,
    image_url TEXT,
    calories_per_minute DECIMAL(4, 2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS (public read)
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view exercises" ON public.exercises
    FOR SELECT USING (is_active = true);

-- ============================================
-- USER PROGRESS TABLE (for tracking weight, measurements over time)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    weight DECIMAL(5, 2),
    body_fat_percentage DECIMAL(4, 2),
    muscle_mass DECIMAL(5, 2),
    chest DECIMAL(5, 2),
    waist DECIMAL(5, 2),
    hips DECIMAL(5, 2),
    arms DECIMAL(5, 2),
    thighs DECIMAL(5, 2),
    notes TEXT,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_progress_user ON public.user_progress(user_id);
CREATE INDEX idx_user_progress_date ON public.user_progress(recorded_at DESC);

-- Enable RLS
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress" ON public.user_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress" ON public.user_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own progress" ON public.user_progress
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, is_guest)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name'),
        COALESCE((NEW.raw_user_meta_data->>'is_guest')::boolean, false)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function on new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to gyms
CREATE TRIGGER update_gyms_updated_at
    BEFORE UPDATE ON public.gyms
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================
-- STORAGE BUCKETS (run in Supabase Dashboard > Storage)
-- ============================================
-- Note: Create these buckets manually in the Supabase Dashboard:
-- 1. profile-images (public)
-- 2. workout-images (private)
-- 3. meal-images (private)
-- 4. gym-images (public)
-- 5. exercise-videos (public)

-- Enable realtime for tables that need it
ALTER PUBLICATION supabase_realtime ADD TABLE public.workouts;
ALTER PUBLICATION supabase_realtime ADD TABLE public.meals;
ALTER PUBLICATION supabase_realtime ADD TABLE public.challenge_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
