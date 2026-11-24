-- 001_init.sql: Inisialisasi Skema Tabel Kos dan Kebijakan Row Level Security (RLS)
-- Proyek: KosFinder Versi 1

-- 1. Buat Tabel kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    city_or_area VARCHAR(100) NOT NULL,
    monthly_price NUMERIC(12, 2),
    yearly_price NUMERIC(12, 2),
    category VARCHAR(20) NOT NULL CHECK (category IN ('Putra', 'Putri', 'Campur')),
    facilities TEXT[] NOT NULL DEFAULT '{}',
    status VARCHAR(20) NOT NULL DEFAULT 'Tersedia' CHECK (status IN ('Tersedia', 'Penuh')),
    whatsapp_number VARCHAR(20) NOT NULL,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Buat Index untuk Optimasi Kueri Pencarian dan Pemilik
CREATE INDEX IF NOT EXISTS idx_kos_user_id ON public.kos(user_id);
CREATE INDEX IF NOT EXISTS idx_kos_city_area ON public.kos(city_or_area);
CREATE INDEX IF NOT EXISTS idx_kos_category ON public.kos(category);
CREATE INDEX IF NOT EXISTS idx_kos_status ON public.kos(status);

-- 3. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 4. Kebijakan Otorisasi (RLS Policies)

-- Kebijakan 1: Pengunjung publik (anonim & login) dapat membaca seluruh katalog kos
CREATE POLICY "Public read access to all kos"
    ON public.kos
    FOR SELECT
    TO public
    USING (true);

-- Kebijakan 2: Pemilik terautentikasi hanya dapat menambahkan kos atas namanya sendiri
CREATE POLICY "Authenticated owners can insert own kos"
    ON public.kos
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Kebijakan 3: Pemilik terautentikasi hanya dapat mengubah kos miliknya sendiri
CREATE POLICY "Owners can update own kos"
    ON public.kos
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Kebijakan 4: Pemilik terautentikasi hanya dapat menghapus kos miliknya sendiri
CREATE POLICY "Owners can delete own kos"
    ON public.kos
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);
