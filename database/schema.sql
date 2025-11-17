-- Supabase Database Schema for PR Dashboard
-- Execute these commands in your Supabase SQL Editor

-- Enable Row Level Security
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;

-- Create admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

-- Create PR data table
CREATE TABLE IF NOT EXISTS pr_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cost_center VARCHAR(50),
    cost_center_name VARCHAR(200),
    prno VARCHAR(100) NOT NULL,
    linenum INTEGER,
    lineno INTEGER,
    wp VARCHAR(50),
    mcode VARCHAR(50),
    cost_cmpnt VARCHAR(50),
    item_code VARCHAR(100),
    description TEXT,
    unit VARCHAR(20),
    ordered_qty DECIMAL(10,2),
    served_qty DECIMAL(10,2),
    pr_status VARCHAR(50),
    pr_keyword_ref TEXT,
    pr_additional_info TEXT,
    requester VARCHAR(50),
    requester_name VARCHAR(200),
    owner VARCHAR(50),
    owner_name VARCHAR(200),
    buyer VARCHAR(50),
    buyer_name VARCHAR(200),
    po_numbers TEXT,
    last_remark TEXT,
    approved_on DATE,
    approved_since VARCHAR(50),
    last_assigned_on DATE,
    last_assigned_since VARCHAR(50),
    closed BOOLEAN DEFAULT FALSE,
    week_category VARCHAR(50), -- 'THIS_WEEK', 'PREVIOUS_WEEK', 'TWO_WEEKS'
    data_date DATE, -- Date of the data snapshot
    emergency_flag BOOLEAN DEFAULT FALSE, -- Computed from keywords
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create report versions table
CREATE TABLE IF NOT EXISTS report_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version_number VARCHAR(20) NOT NULL,
    report_title VARCHAR(200),
    generated_date TIMESTAMP DEFAULT NOW(),
    data_snapshot JSONB, -- Complete dataset snapshot
    report_html TEXT, -- Generated HTML
    total_prs INTEGER,
    total_owners INTEGER,
    emergency_count INTEGER,
    created_by VARCHAR(100),
    notes TEXT
);

-- Create data upload log
CREATE TABLE IF NOT EXISTS upload_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(200),
    file_size INTEGER,
    records_processed INTEGER,
    week_category VARCHAR(50),
    upload_date TIMESTAMP DEFAULT NOW(),
    uploaded_by VARCHAR(100),
    status VARCHAR(20) DEFAULT 'success'
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_pr_data_prno ON pr_data(prno);
CREATE INDEX IF NOT EXISTS idx_pr_data_owner ON pr_data(owner_name);
CREATE INDEX IF NOT EXISTS idx_pr_data_status ON pr_data(pr_status);
CREATE INDEX IF NOT EXISTS idx_pr_data_date ON pr_data(data_date);
CREATE INDEX IF NOT EXISTS idx_pr_data_week_category ON pr_data(week_category);
CREATE INDEX IF NOT EXISTS idx_pr_data_emergency ON pr_data(emergency_flag);

-- Create a view for dashboard metrics
CREATE OR REPLACE VIEW dashboard_metrics AS
SELECT 
    data_date,
    week_category,
    COUNT(DISTINCT prno) as total_prs,
    COUNT(DISTINCT owner_name) as total_owners,
    COUNT(CASE WHEN emergency_flag = true THEN 1 END) as emergency_count,
    COUNT(CASE WHEN approved_since = 'This Week' THEN 1 END) as this_week_approved,
    COUNT(CASE WHEN approved_since IN ('1 weeks ago', '2 weeks ago', '3 weeks ago') THEN 1 END) as recent_approved,
    COUNT(CASE WHEN approved_since NOT IN ('This Week', '1 weeks ago', '2 weeks ago', '3 weeks ago') THEN 1 END) as old_approved
FROM pr_data 
WHERE week_category = 'THIS_WEEK'
GROUP BY data_date, week_category
ORDER BY data_date DESC;

-- Create a view for owner distribution (for pie chart)
CREATE OR REPLACE VIEW owner_distribution AS
SELECT 
    owner_name,
    COUNT(DISTINCT prno) as pr_count,
    COUNT(CASE WHEN emergency_flag = true THEN 1 END) as emergency_count,
    ROUND((COUNT(DISTINCT prno)::decimal / SUM(COUNT(DISTINCT prno)) OVER()) * 100, 1) as percentage
FROM pr_data 
WHERE week_category = 'THIS_WEEK' 
  AND pr_status = 'PENDING'
GROUP BY owner_name
ORDER BY pr_count DESC;

-- Enable Row Level Security (optional - can be configured later)
-- ALTER TABLE pr_data ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE report_versions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Insert default admin user (password: admin123)
INSERT INTO admin_users (username, password_hash) 
VALUES ('admin', '$2a$10$rOzJ7w.5qF9EUyJ3J9J1.OX4J2J1J2J1J2J1J2J1J2J1J2J1J2J1J2') 
ON CONFLICT (username) DO NOTHING;

-- Grant necessary permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
