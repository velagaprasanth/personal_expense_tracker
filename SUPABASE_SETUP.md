# Supabase Database Setup

## Instructions

1. Go to your Supabase project dashboard: https://yybfsofqeldcqllslpkt.supabase.co
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**
4. Paste the SQL code below
5. Click **Run** or press `Ctrl+Enter`

## SQL Code

```sql
-- Create transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can view their own transactions
CREATE POLICY "Users can view own transactions"
  ON public.transactions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy: Users can insert their own transactions
CREATE POLICY "Users can insert own transactions"
  ON public.transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can update their own transactions
CREATE POLICY "Users can update own transactions"
  ON public.transactions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policy: Users can delete their own transactions
CREATE POLICY "Users can delete own transactions"
  ON public.transactions
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS transactions_user_id_idx ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS transactions_date_idx ON public.transactions(date DESC);
```

## After Running the SQL

Once the table is created, your app will be able to:
- ✅ Add new income and expense transactions
- ✅ View all transactions in real-time
- ✅ Update balances automatically
- ✅ Secure data with Row Level Security (users can only see their own data)

## Testing

1. Run the app: `flutter run`
2. Login or register a new account
3. Click the **+** button at the bottom
4. Add an income or expense
5. Watch it appear instantly on the home screen!
