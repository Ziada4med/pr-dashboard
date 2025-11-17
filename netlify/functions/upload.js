const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase client
const supabase = createClient(
  process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Helper function to detect emergency PRs
const detectEmergency = (record) => {
  const emergencyKeywords = ['emergency', 'urgent', 'critical', 'high priority'];
  const searchFields = [
    record.pr_keyword_ref || '',
    record.pr_additional_info || '',
    record.description || '',
    record.last_remark || ''
  ];
  
  return searchFields.some(field => 
    emergencyKeywords.some(keyword => 
      field.toLowerCase().includes(keyword.toLowerCase())
    )
  );
};

// Helper function to process Excel data
const processExcelData = (jsonData, weekCategory, dataDate) => {
  return jsonData.map(row => ({
    cost_center: row.COST_CENTER,
    cost_center_name: row.COST_CENTER_NAME,
    prno: row.PRNO,
    linenum: row.LINENUM,
    lineno: row.LINENO,
    wp: row.WP,
    mcode: row.MCODE,
    cost_cmpnt: row.COST_CMPNT,
    item_code: row.ITEM_CODE,
    description: row.DESC,
    unit: row.UNIT,
    ordered_qty: row.ORDERED_QTY,
    served_qty: row.SERVED_QTY,
    pr_status: row.PR_STATUS,
    pr_keyword_ref: row.PR_KEYWORD_REF,
    pr_additional_info: row.PR_ADDITIONAL_INFO,
    requester: row.REQUESTER,
    requester_name: row.REQUESTER_NAME,
    owner: row.OWNER,
    owner_name: row.OWNER_NAME,
    buyer: row.BUYER,
    buyer_name: row.BUYER_NAME,
    po_numbers: row.PO_NUMBERS,
    last_remark: row.LAST_REMARK,
    approved_on: row.APPROVED_ON ? new Date(row.APPROVED_ON) : null,
    approved_since: row.APPROVED_SINCE,
    last_assigned_on: row.LAST_ASSIGNED_ON ? new Date(row.LAST_ASSIGNED_ON) : null,
    last_assigned_since: row.LAST_ASSIGNED_SINCE,
    closed: row.CLOSED || false,
    week_category: weekCategory,
    data_date: dataDate,
    emergency_flag: detectEmergency(row)
  }));
};

exports.handler = async (event, context) => {
  // Enable CORS
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
  };

  // Handle preflight requests
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: 'CORS preflight' })
    };
  }

  // Only allow POST requests
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
    // Parse the request body
    const { data, weekCategory, dataDate, filename } = JSON.parse(event.body);

    if (!data || !weekCategory || !dataDate) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'Missing required fields' })
      };
    }

    // Process the Excel data
    const processedData = processExcelData(data, weekCategory, dataDate);

    // Delete existing data for this week category and date
    const { error: deleteError } = await supabase
      .from('pr_data')
      .delete()
      .eq('week_category', weekCategory)
      .eq('data_date', dataDate);

    if (deleteError) {
      console.error('Delete error:', deleteError);
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({ error: 'Failed to clear existing data' })
      };
    }

    // Insert new data in batches
    const batchSize = 1000;
    let totalInserted = 0;

    for (let i = 0; i < processedData.length; i += batchSize) {
      const batch = processedData.slice(i, i + batchSize);
      const { error: insertError } = await supabase
        .from('pr_data')
        .insert(batch);

      if (insertError) {
        console.error('Insert error:', insertError);
        return {
          statusCode: 500,
          headers,
          body: JSON.stringify({ error: 'Failed to insert data batch' })
        };
      }

      totalInserted += batch.length;
    }

    // Log the upload
    await supabase
      .from('upload_log')
      .insert({
        filename: filename || 'Unknown',
        file_size: JSON.stringify(data).length,
        records_processed: totalInserted,
        week_category: weekCategory,
        uploaded_by: 'Netlify User'
      });

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        message: 'Upload successful',
        recordsProcessed: totalInserted,
        weekCategory,
        dataDate
      })
    };

  } catch (error) {
    console.error('Function error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};
