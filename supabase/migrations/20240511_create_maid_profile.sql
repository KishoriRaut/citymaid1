-- Create a function to handle maid profile creation with RLS bypass
create or replace function create_maid_profile(profile_data jsonb)
returns jsonb
language plpgsql
security definer
as $$
declare
    new_profile_id uuid;
begin
    -- Insert the profile and get the ID
    insert into maid_profiles (
        full_name,
        age_group,
        gender,
        marital_status,
        email,
        phone,
        experience,
        available_from,
        preferred_time,
        expected_salary,
        major_city,
        specific_areas,
        willing_to_travel,
        travel_distance,
        nationality,
        religion,
        education,
        documents,
        languages,
        about,
        skills,
        profile_photo,
        user_id
    ) values (
        profile_data->>'full_name',
        profile_data->>'age_group',
        profile_data->>'gender',
        profile_data->>'marital_status',
        profile_data->>'email',
        profile_data->>'phone',
        profile_data->>'experience',
        profile_data->>'available_from',
        profile_data->>'preferred_time',
        (profile_data->>'expected_salary')::integer,
        profile_data->>'major_city',
        (profile_data->>'specific_areas')::text[],
        (profile_data->>'willing_to_travel')::boolean,
        (profile_data->>'travel_distance')::integer,
        profile_data->>'nationality',
        profile_data->>'religion',
        profile_data->>'education',
        profile_data->>'documents',
        (profile_data->>'languages')::text[],
        profile_data->>'about',
        (profile_data->>'skills')::text[],
        profile_data->>'profile_photo',
        profile_data->>'user_id'
    )
    returning id into new_profile_id;

    -- Return the new profile ID
    return jsonb_build_object('id', new_profile_id);
end;
$$;

-- Grant execute permission to authenticated users
grant execute on function create_maid_profile(jsonb) to authenticated;
grant execute on function create_maid_profile(jsonb) to service_role; 