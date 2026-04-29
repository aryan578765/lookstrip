-- LooksTrip collaboration and sync patch.
-- Run after supabase_migration.sql. Safe to re-run.

CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_phone_unique
  ON public.profiles(phone)
  WHERE phone IS NOT NULL;

CREATE OR REPLACE FUNCTION public.find_profile_by_phone(target_phone text)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT p.id
  FROM public.profiles p
  WHERE auth.uid() IS NOT NULL
    AND p.phone = target_phone
  LIMIT 1
$$;

GRANT EXECUTE ON FUNCTION public.find_profile_by_phone(text) TO authenticated;

CREATE OR REPLACE FUNCTION public.is_trip_owner_or_collaborator(
  target_trip_id text,
  allowed_roles text[] DEFAULT ARRAY['owner', 'editor', 'viewer']
)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.trips t
    WHERE t.id = target_trip_id
      AND t.user_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1
    FROM public.trip_collaborators c
    WHERE c.trip_id = target_trip_id
      AND c.user_id = auth.uid()
      AND c.role = ANY(allowed_roles)
  )
$$;

GRANT EXECUTE ON FUNCTION public.is_trip_owner_or_collaborator(text, text[])
  TO authenticated;

DROP POLICY IF EXISTS "Users can CRUD own trips" ON public.trips;
DROP POLICY IF EXISTS "Users can select accessible trips" ON public.trips;
CREATE POLICY "Users can select accessible trips"
  ON public.trips FOR SELECT
  USING (public.is_trip_owner_or_collaborator(id));

DROP POLICY IF EXISTS "Users can insert own trips" ON public.trips;
CREATE POLICY "Users can insert own trips"
  ON public.trips FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Owners and editors can update trips" ON public.trips;
CREATE POLICY "Owners and editors can update trips"
  ON public.trips FOR UPDATE
  USING (public.is_trip_owner_or_collaborator(id, ARRAY['owner', 'editor']))
  WITH CHECK (public.is_trip_owner_or_collaborator(id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners can delete trips" ON public.trips;
CREATE POLICY "Owners can delete trips"
  ON public.trips FOR DELETE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Trip owners can manage itinerary" ON public.itinerary_items;
DROP POLICY IF EXISTS "Accessible users can view itinerary" ON public.itinerary_items;
CREATE POLICY "Accessible users can view itinerary"
  ON public.itinerary_items FOR SELECT
  USING (public.is_trip_owner_or_collaborator(trip_id));

DROP POLICY IF EXISTS "Owners and editors can insert itinerary" ON public.itinerary_items;
CREATE POLICY "Owners and editors can insert itinerary"
  ON public.itinerary_items FOR INSERT
  WITH CHECK (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners and editors can update itinerary" ON public.itinerary_items;
CREATE POLICY "Owners and editors can update itinerary"
  ON public.itinerary_items FOR UPDATE
  USING (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']))
  WITH CHECK (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners and editors can delete itinerary" ON public.itinerary_items;
CREATE POLICY "Owners and editors can delete itinerary"
  ON public.itinerary_items FOR DELETE
  USING (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Trip owners can manage expenses" ON public.expenses;
DROP POLICY IF EXISTS "Accessible users can view expenses" ON public.expenses;
CREATE POLICY "Accessible users can view expenses"
  ON public.expenses FOR SELECT
  USING (public.is_trip_owner_or_collaborator(trip_id));

DROP POLICY IF EXISTS "Owners and editors can insert expenses" ON public.expenses;
CREATE POLICY "Owners and editors can insert expenses"
  ON public.expenses FOR INSERT
  WITH CHECK (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners and editors can update expenses" ON public.expenses;
CREATE POLICY "Owners and editors can update expenses"
  ON public.expenses FOR UPDATE
  USING (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']))
  WITH CHECK (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners and editors can delete expenses" ON public.expenses;
CREATE POLICY "Owners and editors can delete expenses"
  ON public.expenses FOR DELETE
  USING (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Trip owners can manage packing" ON public.packing_items;
DROP POLICY IF EXISTS "Accessible users can view packing" ON public.packing_items;
CREATE POLICY "Accessible users can view packing"
  ON public.packing_items FOR SELECT
  USING (public.is_trip_owner_or_collaborator(trip_id));

DROP POLICY IF EXISTS "Owners and editors can insert packing" ON public.packing_items;
CREATE POLICY "Owners and editors can insert packing"
  ON public.packing_items FOR INSERT
  WITH CHECK (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners and editors can update packing" ON public.packing_items;
CREATE POLICY "Owners and editors can update packing"
  ON public.packing_items FOR UPDATE
  USING (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']))
  WITH CHECK (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Owners and editors can delete packing" ON public.packing_items;
CREATE POLICY "Owners and editors can delete packing"
  ON public.packing_items FOR DELETE
  USING (public.is_trip_owner_or_collaborator(trip_id, ARRAY['owner', 'editor']));

DROP POLICY IF EXISTS "Trip owners can manage collaborators" ON public.trip_collaborators;
DROP POLICY IF EXISTS "Owners can manage collaborators" ON public.trip_collaborators;
CREATE POLICY "Owners can manage collaborators"
  ON public.trip_collaborators FOR ALL
  USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can see own collaborations" ON public.trip_collaborators;
DROP POLICY IF EXISTS "Trip participants can view collaborators" ON public.trip_collaborators;
CREATE POLICY "Trip participants can view collaborators"
  ON public.trip_collaborators FOR SELECT
  USING (public.is_trip_owner_or_collaborator(trip_id));

CREATE OR REPLACE FUNCTION public.sync_trip_with_itinerary(
  trip_payload jsonb,
  itinerary_payload jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF trip_payload->>'user_id' IS DISTINCT FROM auth.uid()::text THEN
    RAISE EXCEPTION 'Cannot sync a trip for another user';
  END IF;

  INSERT INTO public.trips (
    id,
    user_id,
    title,
    destination,
    emoji,
    start_date,
    end_date,
    status,
    days,
    budget,
    created_at,
    updated_at
  )
  VALUES (
    trip_payload->>'id',
    (trip_payload->>'user_id')::uuid,
    trip_payload->>'title',
    trip_payload->>'destination',
    COALESCE(trip_payload->>'emoji', ''),
    (trip_payload->>'start_date')::timestamptz,
    (trip_payload->>'end_date')::timestamptz,
    COALESCE(trip_payload->>'status', 'upcoming'),
    COALESCE((trip_payload->>'days')::integer, 1),
    trip_payload->>'budget',
    COALESCE((trip_payload->>'created_at')::timestamptz, now()),
    COALESCE((trip_payload->>'updated_at')::timestamptz, now())
  )
  ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    destination = EXCLUDED.destination,
    emoji = EXCLUDED.emoji,
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    status = EXCLUDED.status,
    days = EXCLUDED.days,
    budget = EXCLUDED.budget,
    updated_at = EXCLUDED.updated_at;

  DELETE FROM public.itinerary_items
  WHERE trip_id = trip_payload->>'id';

  INSERT INTO public.itinerary_items (
    trip_id,
    day_number,
    day_title,
    time,
    title,
    description,
    emoji,
    sort_order
  )
  SELECT
    item.trip_id,
    item.day_number,
    item.day_title,
    item.time,
    item.title,
    COALESCE(item.description, ''),
    COALESCE(item.emoji, ''),
    COALESCE(item.sort_order, 0)
  FROM jsonb_to_recordset(itinerary_payload) AS item(
    trip_id text,
    day_number integer,
    day_title text,
    time text,
    title text,
    description text,
    emoji text,
    sort_order integer
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.sync_trip_with_itinerary(jsonb, jsonb)
  TO authenticated;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.trip_collaborators;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
