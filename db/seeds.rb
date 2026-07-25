# Development seed data for Mission Oak Music Department.
# This file is written to be idempotent so it can be run multiple times.

# unless Rails.env.development?
# 	abort "db:seed is restricted to development for this dataset. Current env: #{Rails.env}"
# end

puts "Seeding Tulare Western Music Department development data..."

district = District.find_or_create_by!(name: "Tulare Joint Union High School District")
district.update!(
	city: "Tulare",
	state: "CA",
	description: "Public high school district serving the greater Tulare area."
)

school = School.find_or_create_by!(name: "Tulare Western")
school.update!(
	district: district,
	city: "Tulare",
	state: "CA",
	established: Date.new(1890, 1, 1),
	description: "Home of the Tulare Western Music Department.",
	hero_title: "Tulare Western Music Department",
	call_to_action: "Support our students through events, donations, and volunteer service.",
	contact_us: "Questions? Reach us through the directors listed below.",
	about: "The Tulare Western music program supports concert, marching, jazz, percussion, and color guard students year-round.",
	home_page_image_urls: "https://images.unsplash.com/photo-1511192336575-5a79af67a629,https://images.unsplash.com/photo-1458560871784-56d23406c091,https://images.unsplash.com/photo-1507838153414-b4b713384a76",
	calendar_url: "https://calendar.google.com",
	director_name: "Michael Reynolds",
	director_phone: "(559) 555-0102",
	director_email: "michael.reynolds@tulare.k12.ca.us",
	percussion_director_name: "",
	percussion_director_phone: "",
	percussion_director_email: "",
	default_image: "https://images.unsplash.com/photo-1465847899084-d164df4dedc6",
	performance_absence_form: "https://example.org/forms/performance-absence",
	rehearsal_absence_form: "https://example.org/forms/rehearsal-absence",
	handbook_contract_form: "https://example.org/forms/handbook-contract"
)

program_definitions = [
	{
		name: "Advanced Band",
		short_name: "Advanced",
		period: 1,
		description: "Advanced",
		hero_title: "Advanced Band",
		detailed_description: "Upper-level wind ensemble focused on tone, blend, and advanced repertoire.",
		circuit: "CMEA",
		ig_handle: "@advanced_band"
	},
	{
		name: "Orchestra",
		short_name: "Orchestra",
		period: 2,
		description: "Orchestra",
		hero_title: "Orchestra",
		detailed_description: "String and full ensemble literature with an emphasis on musicianship and technique.",
		circuit: "CMEA",
		ig_handle: "@orchestra"
	},
	{
		name: "Drumline",
		short_name: "Drumline",
		period: 3,
		description: "Drumline",
		hero_title: "Drumline",
		detailed_description: "Battery and front ensemble training for field and indoor performance.",
		circuit: "WGI",
		ig_handle: "@drumline"
	},
	{
		name: "Intermediate Band",
		short_name: "Intermediate",
		period: 4,
		description: "Intermediate",
		hero_title: "Intermediate Band",
		detailed_description: "Developing ensemble focused on foundational tone, rhythm, and sight reading.",
		circuit: "CMEA",
		ig_handle: "@intermediate_band"
	},
	{
		name: "Jazz Band",
		short_name: "Jazz",
		period: 5,
		description: "Jazz",
		hero_title: "Jazz Band",
		detailed_description: "Small and large jazz ensemble repertoire, improvisation, and style.",
		circuit: "CCJEA",
		ig_handle: "@jazz_band"
	},
	{
		name: "Color Guard",
		short_name: "Color Guard",
		period: 6,
		description: "Color Guard",
		hero_title: "Color Guard",
		detailed_description: "Movement, dance, and equipment work supporting marching and winter programs.",
		circuit: "WGASC",
		ig_handle: "@colorguard"
	}
]

programs_by_short_name = {}

program_definitions.each do |attrs|
	program = Program.find_or_create_by!(school: school, name: attrs[:name])
	program.update!(
		short_name: attrs[:short_name],
		description: attrs[:description],
		year_established: Date.new(1985, 1, 1),
		main_gallery_image_url: "https://images.unsplash.com/photo-1519892300165-cb5542fb47c7",
		about_image_url: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae",
		hero_title: attrs[:hero_title],
		detailed_description: attrs[:detailed_description],
		image_gallery_urls: "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0,https://images.unsplash.com/photo-1465847899084-d164df4dedc6,https://images.unsplash.com/photo-1511192336575-5a79af67a629",
		calendar_url: "https://calendar.google.com",
		circuit: attrs[:circuit],
		ig_handle: attrs[:ig_handle],
		period: attrs[:period]
	)
	programs_by_short_name[attrs[:short_name]] = program
end

director = Director.find_or_initialize_by(email: "kheffy.cervantez@gmail.com")
if director.new_record?
	director.password = "b4nd4dmin1004"
	director.password_confirmation = "b4nd4dmin1004"
end
director.update!(
	first_name: "Kheffy",
	last_name: "Cervantez",
	phone_number: "(559) 555-0100",
	title: "Director of Website",
	school_name: school.name,
	school_address: "755 E Tulare Ave, Tulare, CA"
)

programs_by_short_name.each_value do |program|
	fundraiser = Fundraiser.find_or_create_by!(program: program, title: "#{program.short_name} Fall Campaign")
	fundraiser.update!(
		description: "Support instruments, travel, uniforms, and student scholarships for #{program.name}.",
		goal: "$12,000",
		call_to_action: "Donate now to support #{program.short_name} students.",
		main_image: "https://images.unsplash.com/photo-1465847899084-d164df4dedc6",
		start_date: Time.zone.parse("2026-08-15 08:00"),
		end_date: Time.zone.parse("2026-10-31 23:59")
	)
end

puts "Seed complete."
puts "Districts: #{District.count}"
puts "Schools: #{School.count}"
puts "Programs: #{Program.count}"
puts "Directors: #{Director.count}"
puts "Fundraisers: #{Fundraiser.count}"
