create table if not exists public.marketing_occasions (
  id uuid primary key,
  site_profile text not null default 'teniski',
  title text not null,
  type text not null check (type in ('month', 'evergreen', 'top')),
  month text,
  campaign_start date,
  campaign_end date,
  is_evergreen_period boolean not null default false,
  theme text,
  tags text[] not null default '{}',
  audience text,
  offer text,
  offer_texts text[] not null default '{}',
  cta text,
  category_image_url text,
  gallery_url text,
  asset_urls text[] not null default '{}',
  background_color text,
  products jsonb not null default '[]'::jsonb,
  ad_texts text[] not null default '{}',
  email_html text,
  blog_post_html text,
  updated_at timestamptz not null default now()
);

create table if not exists public.marketing_profiles (
  id text primary key,
  label text not null,
  title text,
  intro text,
  updated_at timestamptz not null default now()
);

create table if not exists public.marketing_backups (
  id uuid primary key,
  site_profile text not null default 'teniski',
  label text not null,
  payload jsonb not null,
  created_at timestamptz not null default now()
);

alter table public.marketing_occasions
add column if not exists offer_texts text[] not null default '{}';

alter table public.marketing_occasions
add column if not exists gallery_url text;

alter table public.marketing_occasions
add column if not exists asset_urls text[] not null default '{}';

alter table public.marketing_occasions
add column if not exists background_color text;

alter table public.marketing_occasions
add column if not exists blog_post_html text;

alter table public.marketing_occasions
add column if not exists campaign_start date;

alter table public.marketing_occasions
add column if not exists campaign_end date;

alter table public.marketing_occasions
add column if not exists is_evergreen_period boolean not null default false;

alter table public.marketing_occasions
add column if not exists site_profile text not null default 'teniski';

alter table public.marketing_occasions enable row level security;
alter table public.marketing_profiles enable row level security;
alter table public.marketing_backups enable row level security;

grant select, insert, update, delete on public.marketing_occasions to anon, authenticated;
grant select, insert, update, delete on public.marketing_occasions to service_role;
grant select, insert, update, delete on public.marketing_profiles to anon, authenticated;
grant select, insert, update, delete on public.marketing_profiles to service_role;
grant select, insert, update, delete on public.marketing_backups to anon, authenticated;
grant select, insert, update, delete on public.marketing_backups to service_role;

drop policy if exists "Allow public reads for marketing occasions" on public.marketing_occasions;
drop policy if exists "Allow public writes for marketing occasions" on public.marketing_occasions;
drop policy if exists "Allow public reads for marketing profiles" on public.marketing_profiles;
drop policy if exists "Allow public writes for marketing profiles" on public.marketing_profiles;
drop policy if exists "Allow public reads for marketing backups" on public.marketing_backups;
drop policy if exists "Allow public writes for marketing backups" on public.marketing_backups;
drop policy if exists "Allow public reads for marketing assets" on storage.objects;
drop policy if exists "Allow public uploads for marketing assets" on storage.objects;
drop policy if exists "Allow public updates for marketing assets" on storage.objects;
drop policy if exists "Allow public deletes for marketing assets" on storage.objects;

create policy "Allow public reads for marketing occasions"
on public.marketing_occasions
for select
to anon, authenticated
using (true);

create policy "Allow public writes for marketing occasions"
on public.marketing_occasions
for all
to anon, authenticated
using (true)
with check (true);

create policy "Allow public reads for marketing profiles"
on public.marketing_profiles
for select
to anon, authenticated
using (true);

create policy "Allow public writes for marketing profiles"
on public.marketing_profiles
for all
to anon, authenticated
using (true)
with check (true);

create policy "Allow public reads for marketing backups"
on public.marketing_backups
for select
to anon, authenticated
using (true);

create policy "Allow public writes for marketing backups"
on public.marketing_backups
for all
to anon, authenticated
using (true)
with check (true);

create index if not exists marketing_occasions_type_idx on public.marketing_occasions (type);
create index if not exists marketing_occasions_site_profile_idx on public.marketing_occasions (site_profile);
create index if not exists marketing_occasions_month_idx on public.marketing_occasions (month);
create index if not exists marketing_occasions_updated_at_idx on public.marketing_occasions (updated_at desc);
create index if not exists marketing_profiles_updated_at_idx on public.marketing_profiles (updated_at desc);
create index if not exists marketing_backups_site_profile_created_at_idx on public.marketing_backups (site_profile, created_at desc);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'marketing-assets',
  'marketing-assets',
  true,
  20971520,
  array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'application/pdf',
    'video/mp4'
  ]
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Allow public reads for marketing assets"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'marketing-assets');

create policy "Allow public uploads for marketing assets"
on storage.objects
for insert
to anon, authenticated
with check (bucket_id = 'marketing-assets');

create policy "Allow public updates for marketing assets"
on storage.objects
for update
to anon, authenticated
using (bucket_id = 'marketing-assets')
with check (bucket_id = 'marketing-assets');

create policy "Allow public deletes for marketing assets"
on storage.objects
for delete
to anon, authenticated
using (bucket_id = 'marketing-assets');
