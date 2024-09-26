drop schema if exists app_public cascade;
create schema app_public;

DROP TABLE IF EXISTS app_public.content_types;

CREATE TABLE IF NOT EXISTS app_public.content_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS app_public.fields;

CREATE TABLE IF NOT EXISTS app_public.fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type_id UUID REFERENCES app_public.content_types(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    required BOOLEAN DEFAULT false,
    is_unique BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists app_public.entries;

create table if not exists app_public.entries (
  id uuid primary key default gen_random_uuid(),
  content_type_id UUID REFERENCES app_public.content_types(id) ON DELETE CASCADE,
  tenant_id UUID default gen_random_uuid(),
  created_at timestamp default current_timestamp,
  updated_at timestamp default current_timestamp
);

create table if not exists app_public.field_values (
  id uuid primary key default gen_random_uuid(),
  entry_id UUID REFERENCES app_public.entries(id) ON DELETE CASCADE,
  field_id UUID REFERENCES app_public.fields(id) ON DELETE CASCADE,
  string_value TEXT,
  number_value DOUBLE PRECISION,
  boolean_value BOOLEAN,
  created_at timestamp default current_timestamp,
  updated_at timestamp default current_timestamp
);

-- Ensure each field is only set once per entry
alter table app_public.field_values
  add constraint field_values_entry_id_field_id_key
  unique (entry_id, field_id);

INSERT INTO app_public.content_types (id, name)
VALUES
  ('7d9f78a2-8a29-4db3-97f2-7e2e1af0c799', 'BlogPost');

INSERT INTO app_public.content_types (id, name)
VALUES
  ('bf73c419-5d78-4d1f-b109-6da04d07775f', 'Page');  

INSERT INTO app_public.fields (id, content_type_id, name, type)
VALUES
  ('ecac9d22-59b6-464b-95b6-4e08762fd92e', '7d9f78a2-8a29-4db3-97f2-7e2e1af0c799', 'title', 'String'),
  ('ed63b5e2-b1a4-4bc5-bb15-d5d158632b7c', '7d9f78a2-8a29-4db3-97f2-7e2e1af0c799', 'published', 'Boolean'),
  ('af925418-d9db-43b9-8143-d52da87523d2', '7d9f78a2-8a29-4db3-97f2-7e2e1af0c799', 'views', 'Number');

INSERT INTO app_public.fields (id, content_type_id, name, type)
VALUES
  ('5ea4f405-16df-41d3-9c8d-5c263fd5a3d4', 'bf73c419-5d78-4d1f-b109-6da04d07775f', 'title', 'String'),
  ('522740c1-d44f-42b0-95e5-4665af858bae', 'bf73c419-5d78-4d1f-b109-6da04d07775f', 'published', 'Boolean'),
  ('18fea5a7-fbdc-4adf-b21a-94305bf6e8e7', 'bf73c419-5d78-4d1f-b109-6da04d07775f', 'views', 'Number');  

