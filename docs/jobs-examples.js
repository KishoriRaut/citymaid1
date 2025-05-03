// Example of how to use the job functions in your frontend code

// Create a new job
async function createJob() {
    const { data, error } = await supabase.rpc('create_job', {
        p_title: 'House Cleaning',
        p_description: 'Looking for a reliable house cleaner',
        p_location: 'New York',
        p_job_type: 'weekly',
        p_hourly_rate: 25
    });

    if (error) {
        console.error('Error creating job:', error);
        return;
    }

    console.log('Job created with ID:', data);
}

// Update a job
async function updateJob(jobId) {
    const { data, error } = await supabase.rpc('update_job', {
        p_job_id: jobId,
        p_title: 'Updated Title',
        p_description: 'Updated description',
        p_location: 'New Location',
        p_job_type: 'monthly',
        p_hourly_rate: 30,
        p_status: 'active'
    });

    if (error) {
        console.error('Error updating job:', error);
        return;
    }

    console.log('Job updated successfully');
}

// Delete a job
async function deleteJob(jobId) {
    const { data, error } = await supabase.rpc('delete_job', {
        p_job_id: jobId
    });

    if (error) {
        console.error('Error deleting job:', error);
        return;
    }

    console.log('Job deleted successfully');
}

// Get job details
async function getJobDetails(jobId) {
    const { data, error } = await supabase.rpc('get_job_details', {
        p_job_id: jobId
    });

    if (error) {
        console.error('Error getting job details:', error);
        return;
    }

    console.log('Job details:', data);
    return data;
} 