-- ╔══════════════════════════════════════════════════════════════════╗
-- ║             LooksTrip — Final Supabase SQL Migration           ║
-- ║                  Run this ONCE in SQL Editor                   ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- ═══════════════════════════════════════════════
-- 1. PROFILES (already exists — skip if done)
-- ═══════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  phone text,
  name text,
  avatar_url text,
  travel_styles text[] DEFAULT '{}',
  preferences jsonb DEFAULT '{}',
  is_profile_complete boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  PRIMARY KEY (id)
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);


-- ═══════════════════════════════════════════════
-- 2. TRIPS
-- ═══════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.trips (
  id text NOT NULL,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  destination text NOT NULL,
  emoji text DEFAULT '🌍',
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  status text DEFAULT 'upcoming',
  days integer NOT NULL,
  budget text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  PRIMARY KEY (id)
);

ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can CRUD own trips" ON public.trips;
CREATE POLICY "Users can CRUD own trips"
  ON public.trips FOR ALL
  USING (auth.uid() = user_id);


-- ═══════════════════════════════════════════════
-- 3. ITINERARY ITEMS
-- ═══════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.itinerary_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id text NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  day_number integer NOT NULL,
  day_title text NOT NULL,
  time text NOT NULL,
  title text NOT NULL,
  description text DEFAULT '',
  emoji text DEFAULT '📍',
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (id)
);

ALTER TABLE public.itinerary_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Trip owners can manage itinerary" ON public.itinerary_items;
CREATE POLICY "Trip owners can manage itinerary"
  ON public.itinerary_items FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );


-- ═══════════════════════════════════════════════
-- 4. EXPENSES
-- ═══════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.expenses (
  id text NOT NULL,
  trip_id text NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  user_id text,
  category text NOT NULL,
  amount double precision NOT NULL,
  currency text DEFAULT 'USD',
  note text,
  date timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (id)
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Trip owners can manage expenses" ON public.expenses;
CREATE POLICY "Trip owners can manage expenses"
  ON public.expenses FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );


-- ═══════════════════════════════════════════════
-- 5. TRIP COLLABORATORS
-- ═══════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.trip_collaborators (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id text NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text DEFAULT 'editor',
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (id),
  UNIQUE (trip_id, user_id)
);

ALTER TABLE public.trip_collaborators ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Trip owners can manage collaborators" ON public.trip_collaborators;
CREATE POLICY "Trip owners can manage collaborators"
  ON public.trip_collaborators FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can see own collaborations" ON public.trip_collaborators;
CREATE POLICY "Users can see own collaborations"
  ON public.trip_collaborators FOR SELECT
  USING (auth.uid() = user_id);


-- ═══════════════════════════════════════════════
-- 6. PACKING ITEMS
-- ═══════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.packing_items (
  id text NOT NULL,
  trip_id text NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  item_name text NOT NULL,
  category text DEFAULT 'general',
  is_packed boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (id)
);

ALTER TABLE public.packing_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Trip owners can manage packing" ON public.packing_items;
CREATE POLICY "Trip owners can manage packing"
  ON public.packing_items FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );


-- ═══════════════════════════════════════════════
-- 7. ENABLE REALTIME
-- ═══════════════════════════════════════════════
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.trips;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.itinerary_items;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.expenses;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.packing_items;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;


-- ═══════════════════════════════════════════════
-- 8. INDEXES
-- ═══════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON public.trips(user_id);
CREATE INDEX IF NOT EXISTS idx_itinerary_trip_id ON public.itinerary_items(trip_id);
CREATE INDEX IF NOT EXISTS idx_expenses_trip_id ON public.expenses(trip_id);
CREATE INDEX IF NOT EXISTS idx_packing_trip_id ON public.packing_items(trip_id);
CREATE INDEX IF NOT EXISTS idx_collab_trip_id ON public.trip_collaborators(trip_id);
CREATE INDEX IF NOT EXISTS idx_collab_user_id ON public.trip_collaborators(user_id);


-- ═══════════════════════════════════════════════
-- 9. AUTO-UPDATE TIMESTAMP TRIGGER
-- ═══════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_trips_updated ON public.trips;
CREATE TRIGGER on_trips_updated
  BEFORE UPDATE ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                     ✅ MIGRATION COMPLETE                      ║
-- ║  6 tables · RLS enabled · Realtime enabled · Indexes created   ║
-- ╚══════════════════════════════════════════════════════════════════╝
