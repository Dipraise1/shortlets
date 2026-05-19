-- ============================================================
-- Rosera Backend Schema
-- ============================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================
create table public.profiles (
  id           uuid references auth.users(id) on delete cascade primary key,
  name         text,
  email        text,
  avatar_url   text,
  phone        text,
  created_at   timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- AGENTS
-- ============================================================
create table public.agents (
  id         uuid default uuid_generate_v4() primary key,
  user_id    uuid references auth.users(id) on delete set null,
  name       text not null,
  email      text not null,
  phone      text,
  avatar_url text,
  verified   boolean default false,
  created_at timestamptz default now()
);

alter table public.agents enable row level security;

create policy "Agents are viewable by everyone"
  on public.agents for select using (true);

-- ============================================================
-- PROPERTIES
-- ============================================================
create table public.properties (
  id              uuid default uuid_generate_v4() primary key,
  agent_id        uuid references public.agents(id) on delete set null,
  name            text not null,
  location        text not null,
  city            text not null,
  price           numeric(12,2) not null,
  image_url       text,
  description     text,
  bedrooms        integer default 1,
  bathrooms       integer default 1,
  property_area   text,
  cctv            integer default 0,
  parking_spots   integer default 0,
  year_built      integer,
  property_type   text check (property_type in ('apartment','house')) default 'apartment',
  listing_type    text check (listing_type in ('shortlet','rent')) default 'shortlet',
  rating          numeric(3,1) default 4.5,
  is_active       boolean default true,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

alter table public.properties enable row level security;

create policy "Active properties are viewable by everyone"
  on public.properties for select
  using (is_active = true);

create policy "Agents can insert their own properties"
  on public.properties for insert
  with check (agent_id in (select id from public.agents where user_id = auth.uid()));

create policy "Agents can update their own properties"
  on public.properties for update
  using (agent_id in (select id from public.agents where user_id = auth.uid()));

-- Index for common query patterns
create index properties_city_idx on public.properties(city);
create index properties_listing_type_idx on public.properties(listing_type);
create index properties_property_type_idx on public.properties(property_type);
create index properties_rating_idx on public.properties(rating desc);

-- ============================================================
-- PROPERTY IMAGES
-- ============================================================
create table public.property_images (
  id          uuid default uuid_generate_v4() primary key,
  property_id uuid references public.properties(id) on delete cascade,
  url         text not null,
  is_primary  boolean default false,
  sort_order  integer default 0,
  created_at  timestamptz default now()
);

alter table public.property_images enable row level security;

create policy "Property images are viewable by everyone"
  on public.property_images for select using (true);

-- ============================================================
-- FAVORITES
-- ============================================================
create table public.favorites (
  id          uuid default uuid_generate_v4() primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  property_id uuid references public.properties(id) on delete cascade not null,
  created_at  timestamptz default now(),
  unique(user_id, property_id)
);

alter table public.favorites enable row level security;

create policy "Users can view their own favorites"
  on public.favorites for select
  using (auth.uid() = user_id);

create policy "Users can add favorites"
  on public.favorites for insert
  with check (auth.uid() = user_id);

create policy "Users can remove their own favorites"
  on public.favorites for delete
  using (auth.uid() = user_id);

-- ============================================================
-- CONVERSATIONS (message threads)
-- ============================================================
create table public.conversations (
  id          uuid default uuid_generate_v4() primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  agent_id    uuid references public.agents(id) on delete set null,
  property_id uuid references public.properties(id) on delete set null,
  last_message text,
  last_message_at timestamptz default now(),
  created_at  timestamptz default now()
);

alter table public.conversations enable row level security;

create policy "Users can view their own conversations"
  on public.conversations for select
  using (auth.uid() = user_id);

create policy "Users can create conversations"
  on public.conversations for insert
  with check (auth.uid() = user_id);

create index conversations_user_idx on public.conversations(user_id, last_message_at desc);

-- ============================================================
-- MESSAGES (real-time)
-- ============================================================
create table public.messages (
  id              uuid default uuid_generate_v4() primary key,
  conversation_id uuid references public.conversations(id) on delete cascade not null,
  sender_id       uuid references auth.users(id) on delete set null not null,
  content         text not null,
  is_read         boolean default false,
  created_at      timestamptz default now()
);

alter table public.messages enable row level security;

create policy "Conversation participants can view messages"
  on public.messages for select
  using (
    conversation_id in (
      select id from public.conversations where user_id = auth.uid()
    )
  );

create policy "Conversation participants can send messages"
  on public.messages for insert
  with check (
    auth.uid() = sender_id and
    conversation_id in (
      select id from public.conversations where user_id = auth.uid()
    )
  );

create policy "Users can mark messages as read"
  on public.messages for update
  using (conversation_id in (select id from public.conversations where user_id = auth.uid()));

create index messages_conversation_idx on public.messages(conversation_id, created_at asc);

-- Enable real-time for messages and conversations
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.conversations;

-- Auto-update conversation last_message on new message
create or replace function public.handle_new_message()
returns trigger language plpgsql security definer as $$
begin
  update public.conversations
  set last_message = new.content,
      last_message_at = new.created_at
  where id = new.conversation_id;
  return new;
end;
$$;

create trigger on_message_created
  after insert on public.messages
  for each row execute procedure public.handle_new_message();

-- ============================================================
-- BOOKINGS
-- ============================================================
create table public.bookings (
  id          uuid default uuid_generate_v4() primary key,
  user_id     uuid references auth.users(id) on delete cascade not null,
  property_id uuid references public.properties(id) on delete cascade not null,
  check_in    date,
  check_out   date,
  status      text check (status in ('pending','confirmed','cancelled','completed')) default 'pending',
  total_price numeric(12,2),
  notes       text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

alter table public.bookings enable row level security;

create policy "Users can view their own bookings"
  on public.bookings for select
  using (auth.uid() = user_id);

create policy "Users can create bookings"
  on public.bookings for insert
  with check (auth.uid() = user_id);

create policy "Users can cancel their own bookings"
  on public.bookings for update
  using (auth.uid() = user_id);

create index bookings_user_idx on public.bookings(user_id, created_at desc);
create index bookings_property_idx on public.bookings(property_id);
