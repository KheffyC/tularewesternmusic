# Staff Feature Implementation Specification

## Overview
Complete Staff management feature for Rails music department website. Includes database models, admin CRUD interface with Administrate, S3 photo uploads via ActiveStorage, public-facing staff page, and school-level feature gating.

## Architecture
- **Feature Flag**: `School#staff_enabled` boolean (default: false) - controls visibility everywhere
- **Admin Access**: Directors with admin role manage staff via `/admin/staff_members`
- **Public Access**: Staff page at `/staff_members` (returns 404 if disabled)
- **Ordering**: Band director always first, then by display_order, then by name

---

## 1. Database Schema

### Migration: Create staff_members table
```ruby
# db/migrate/[timestamp]_create_staff_members.rb
create_table :staff_members do |t|
  t.string :name, null: false
  t.string :title
  t.text :bio
  t.boolean :is_band_director, default: false, null: false
  t.integer :display_order, default: 0
  t.references :school, null: false, foreign_key: true
  t.references :program, foreign_key: true, optional: true
  
  t.timestamps
end
```

### Migration: Add staff_enabled to schools
```ruby
# db/migrate/[timestamp]_add_staff_enabled_to_schools.rb
add_column :schools, :staff_enabled, :boolean, default: false, null: false
```

### Staff Member Model: `app/models/staff_member.rb`
```ruby
class StaffMember < ApplicationRecord
  belongs_to :school
  belongs_to :program, optional: true
  
  has_one_attached :photo
  
  validates :name, presence: true
  
  scope :ordered, -> { order(is_band_director: :desc, display_order: :asc, name: :asc) }
end
```

### School Model: Update `app/models/school.rb`
- Add association: `has_many :staff_members, dependent: :destroy`
- Do NOT add staff_enabled to SchoolDashboard form (intentional - prevent accidental toggling)

---

## 2. Controllers

### Admin Controller: `app/controllers/admin/staff_members_controller.rb`
```ruby
class Admin::StaffMembersController < Admin::ApplicationController
  before_action :require_staff_enabled!
  
  def permitted_attributes
    super + [:photo, :photo_remove]
  end
  
  def update_resource(resource, attribs)
    # Handle photo removal
    if attribs["photo_remove"] == "1"
      resource.photo.purge_later if resource.photo.attached?
      attribs.delete("photo_remove")
    end
    
    super(resource, attribs)
  end
  
  def create_resource(resource)
    resource.school = @school
    resource.program = nil  # All Programs
    resource.display_order = @school.staff_members.count
    super(resource)
  end
  
  private
  
  def require_staff_enabled!
    redirect_to admin_root_path, alert: "Staff feature is not enabled." unless @school&.staff_enabled?
  end
end
```

### Public Controller: `app/controllers/staff_members_controller.rb`
```ruby
class StaffMembersController < ApplicationController
  before_action :require_staff_enabled!

  def index
    @staff_members = StaffMember.where(school: @school).ordered
                                .with_attached_photo
    @boosters = Booster.where(school: @school).order(:created_at) if @school&.boosters_enabled?
  end

  private

  def require_staff_enabled!
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @school&.staff_enabled?
  end
end
```

### Public Boosters Controller: `app/controllers/boosters_controller.rb` (NEW)
```ruby
class BoostersController < ApplicationController
  before_action :require_feature_enabled!

  def index
    @staff_members = StaffMember.where(school: @school).ordered.with_attached_photo
    @boosters = Booster.where(school: @school).order(:created_at)
    @active_tab = "boosters"
    render "staff_members/index"
  end

  private

  def require_feature_enabled!
    render file: "#{Rails.public_path}/404.html", status: :not_found, layout: false unless @school&.boosters_enabled?
  end
end
```

### Admin::ApplicationController: Update `app/controllers/admin/application_controller.rb`
Add after `authenticate_director!`:
```ruby
before_action :set_school

private

def set_school
  @school = School.first
end
```

---

## 3. Dashboard: `app/dashboards/staff_member_dashboard.rb`

```ruby
require "administrate/base_dashboard"

class StaffMemberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id:               Field::Number,
    school:           Field::BelongsTo,
    program:          Field::BelongsTo.with_options(include_blank: true),
    name:             Field::String,
    title:            Field::String,
    bio:              Field::Text,
    is_band_director: Field::Boolean,
    display_order:    Field::Number,
    photo:            Field::String,
    created_at:       Field::DateTime,
    updated_at:       Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    school
    name
    title
    is_band_director
    display_order
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    school
    program
    name
    title
    bio
    is_band_director
    display_order
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    school
    name
    title
    bio
    is_band_director
    display_order
    photo
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(staff_member)
    staff_member.name
  end
end
```

---

## 4. Routes: Update `config/routes.rb`

```ruby
namespace :admin do
  # ... existing routes ...
  resources :staff_members
end

# Public routes
resources :staff_members, only: [:index]
```

---

## 5. Views

### Admin Sidebar: Update `app/views/admin/application/_sidebar.html.erb`
Add after "Galleries" link:
```erb
<% if @school&.staff_enabled? %>
  <%= link_to "Staff", admin_staff_members_path, 
      class: "block px-4 py-3 rounded-lg font-semibold transition #{request.path.start_with?(admin_staff_members_path) ? 'bg-gradient-to-r from-red-600 to-red-700 text-white' : 'text-gray-700 hover:bg-gray-100'}" %>
<% end %>
<% if @school&.boosters_enabled? %>
  <%= link_to "Boosters", admin_boosters_path, 
      class: "block px-4 py-3 rounded-lg font-semibold transition #{request.path.start_with?(admin_boosters_path) ? 'bg-gradient-to-r from-red-600 to-red-700 text-white' : 'text-gray-700 hover:bg-gray-100'}" %>
<% end %>
<% if @school&.fundraisers_enabled? %>
  <%= link_to "Fundraisers", admin_fundraisers_path, 
      class: "block px-4 py-3 rounded-lg font-semibold transition #{request.path.start_with?(admin_fundraisers_path) ? 'bg-gradient-to-r from-red-600 to-red-700 text-white' : 'text-gray-700 hover:bg-gray-100'}" %>
<% end %>
<% if @school&.photo_gallery_enabled? %>
  <%= link_to "Photo Gallery", admin_galleries_path, 
      class: "block px-4 py-3 rounded-lg font-semibold transition #{request.path.start_with?(admin_galleries_path) ? 'bg-gradient-to-r from-red-600 to-red-700 text-white' : 'text-gray-700 hover:bg-gray-100'}" %>
<% end %>
```

### Admin Form: Update `app/views/admin/application/_form.html.erb`
After form attributes definition and column_type detection, add integer column check:
```erb
<% is_integer_column = column_type == :integer %>
```

Add custom photo upload field (staff members only). Find the default string input section and add before it:
```erb
<% elsif attr.to_s == "photo" && resource.is_a?(StaffMember) %>
  <!-- Photo Upload for Staff Members -->
  <label for="<%= resource.class.model_name.param_key %>_<%= attr %>" class="block text-sm font-semibold text-gray-700 mb-2">
    <%= attribute&.label || attr.to_s.humanize %>
  </label>
  
  <div class="space-y-4">
    <!-- File Input -->
    <div class="flex items-center gap-4">
      <%= f.file_field attr, 
          accept: "image/*",
          class: "block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-red-600 file:text-white hover:file:bg-red-700 transition cursor-pointer" %>
    </div>
    
    <!-- Photo Preview -->
    <% if resource.photo.attached? %>
      <div class="mt-4 p-4 bg-gray-100 rounded-lg">
        <p class="text-xs text-gray-600 mb-2">Current photo:</p>
        <%= image_tag resource.photo, alt: "Staff photo", class: "h-40 w-40 object-cover rounded shadow-md" %>
        <div class="mt-3 flex items-center">
          <%= f.check_box :photo_remove, { class: "h-5 w-5 text-red-600 rounded" } %>
          <label for="<%= resource.class.model_name.param_key %>_photo_remove" class="ml-3 text-sm text-gray-700">
            Remove this photo
          </label>
        </div>
      </div>
    <% else %>
      <p class="text-xs text-gray-500">No photo uploaded yet. Upload an image (JPG, PNG, etc.)</p>
    <% end %>
  </div>
```

Update Number field to hide display_order on new staff member records:
```erb
<% elsif attribute&.is_a?(Administrate::Field::Number) || is_integer_column %>
  <% if attr.to_s == "display_order" && resource.is_a?(StaffMember) && resource.new_record? %>
    <!-- Display Order: Hidden on new, shown on edit -->
  <% else %>
    <!-- Number Input -->
    <label for="<%= resource.class.model_name.param_key %>_<%= attr %>" class="block text-sm font-semibold text-gray-700 mb-2">
      <%= attribute&.label || attr.to_s.humanize %>
      <% if attribute&.options&.dig(:required) %>
        <span class="text-red-600">*</span>
      <% end %>
    </label>
    <%= f.number_field attr,
        placeholder: "Enter a number",
        class: "w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-600 transition" %>
  <% end %>
```

### Public Unified Staff/Boosters Index: Create `app/views/staff_members/index.html.erb`
This is a unified page with dynamic header and tab navigation for Staff and Boosters:

```erb
<section class="min-h-screen bg-neutral-950 px-4 py-10 sm:px-6 sm:py-12 lg:px-8 lg:py-16">
  <div class="mx-auto w-full max-w-6xl">

    <%# Page header with dynamic content based on active tab %>
    <div class="mb-16 text-center sm:mb-20">
      <% active_tab = @active_tab || params[:tab] %>
      <% if active_tab == "boosters" && @school&.boosters_enabled? %>
        <span class="inline-flex rounded-full border border-amber-400/40 bg-amber-400/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-amber-200">Our Supporters</span>
        <h1 class="mt-4 text-4xl font-bold tracking-tight text-white sm:text-5xl lg:text-6xl">Boosters</h1>
        <p class="mt-4 mx-auto max-w-2xl text-base leading-relaxed text-white/70 sm:text-lg">
          Thank you to our dedicated boosters who support <%= @school.name %>.
        </p>
      <% else %>
        <span class="inline-flex rounded-full border border-amber-400/40 bg-amber-400/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-amber-200">Our Team</span>
        <h1 class="mt-4 text-4xl font-bold tracking-tight text-white sm:text-5xl lg:text-6xl">Staff</h1>
        <p class="mt-4 mx-auto max-w-2xl text-base leading-relaxed text-white/70 sm:text-lg">
          Meet the directors and staff who make the <%= @school.name %> Band what it is.
        </p>
      <% end %>
    </div>

    <%# Tab Navigation %>
    <div class="mb-12 flex flex-wrap gap-4 border-b-2 border-amber-400/40">
      <% if @school&.staff_enabled? %>
        <% is_staff_active = !active_tab || active_tab != "boosters" %>
        <%= link_to "Our Staff", staff_members_path, class: "px-4 py-3 font-semibold #{is_staff_active ? 'text-white border-b-2 border-amber-400' : 'text-white/60 hover:text-white border-b-2 border-transparent hover:border-amber-400/40'} transition" %>
      <% end %>
      <% if @school&.boosters_enabled? %>
        <% is_boosters_active = active_tab == "boosters" %>
        <%= link_to "Our Boosters", boosters_path, class: "px-4 py-3 font-semibold #{is_boosters_active ? 'text-white border-b-2 border-amber-400' : 'text-white/60 hover:text-white border-b-2 border-transparent hover:border-amber-400/40'} transition" %>
      <% end %>
    </div>

    <%# Content based on active tab %>
    <% if active_tab == "boosters" && @school&.boosters_enabled? %>
      <%= render "staff_members/boosters" %>
    <% else %>
      <%= render "staff_members/staff_members" %>
    <% end %>

  </div>
</section>
```

### Public Staff Members Partial: Create `app/views/staff_members/_staff_members.html.erb`
Displays staff members with featured band director section:

```erb
<% band_director = @staff_members.find(&:is_band_director) %>
<% rest = @staff_members.reject(&:is_band_director) %>

<%# Band Director featured section %>
<% if band_director.present? %>
  <article class="mb-12 flex flex-col gap-8 sm:mb-16 sm:flex-row sm:gap-12">
    <div class="h-80 w-full shrink-0 overflow-hidden rounded-2xl sm:w-80 lg:w-96">
      <% if band_director.photo.attached? %>
        <%= image_tag band_director.photo, alt: band_director.name, class: "h-full w-full object-cover object-top" %>
      <% else %>
        <div class="flex h-full w-full items-center justify-center bg-white/10">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-24 w-24 text-white/30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>
      <% end %>
    </div>

    <div class="flex flex-col justify-center">
      <span class="inline-flex w-fit rounded-full border border-amber-400/40 bg-amber-400/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-amber-200">Band Director</span>
      <h2 class="mt-4 text-2xl font-bold text-white sm:text-3xl"><%= band_director.name %></h2>
      <% if band_director.title.present? %>
        <p class="mt-2 text-base font-semibold uppercase tracking-[0.15em] text-white/60"><%= band_director.title %></p>
      <% end %>
      <% if band_director.bio.present? %>
        <p class="mt-6 text-base leading-relaxed text-white/80"><%= band_director.bio %></p>
      <% end %>
    </div>
  </article>
  <hr class="mb-12 border-t-2 border-amber-400/40 sm:mb-16" />
<% end %>

<%# Rest of staff as sections %>
<% if rest.any? %>
  <% rest.each_with_index do |member, index| %>
    <article class="mb-12 flex flex-col gap-8 sm:mb-16 sm:flex-row sm:gap-12">
      <div class="h-80 w-full shrink-0 overflow-hidden rounded-2xl sm:w-80 lg:w-96">
        <% if member.photo.attached? %>
          <%= image_tag member.photo, alt: member.name, class: "h-full w-full object-cover object-top" %>
        <% else %>
          <div class="flex h-full w-full items-center justify-center bg-white/10">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-20 w-20 text-white/30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </div>
        <% end %>
      </div>

      <div class="flex flex-col justify-center">
        <h3 class="text-2xl font-bold text-white sm:text-3xl"><%= member.name %></h3>
        <% if member.title.present? %>
          <p class="mt-1 text-sm font-semibold uppercase tracking-[0.15em] text-amber-300/80"><%= member.title %></p>
        <% end %>
        <% if member.bio.present? %>
          <p class="mt-4 text-base leading-relaxed text-white/80"><%= member.bio %></p>
        <% end %>
        <% if member.program.present? %>
          <p class="mt-3 text-xs text-white/60"><%= member.program.name %></p>
        <% end %>
      </div>
    </article>
    <% if index < rest.size - 1 %>
      <hr class="mb-12 border-t-2 border-amber-400/40 sm:mb-16" />
    <% end %>
  <% end %>
<% end %>

<% if @staff_members.empty? %>
  <div class="flex min-h-[40vh] flex-col items-center justify-center rounded-2xl border border-white/10 bg-white/5 px-6 text-center">
    <p class="text-lg font-semibold text-white">No staff listed yet.</p>
  </div>
<% end %>
```

### Public Boosters Partial: Create `app/views/staff_members/_boosters.html.erb`
Displays boosters with names, roles, and descriptions (no photos):

```erb
<% if @boosters.any? %>
  <div class="space-y-8 sm:space-y-12">
    <% @boosters.each_with_index do |booster, index| %>
      <article class="flex flex-col gap-6">
        <div>
          <h3 class="text-2xl font-bold text-white sm:text-3xl"><%= booster.full_name %></h3>
          <% if booster.role.present? %>
            <p class="mt-1 text-sm font-semibold uppercase tracking-[0.15em] text-amber-300/80"><%= booster.role %></p>
          <% end %>
          <% if booster.description.present? %>
            <p class="mt-4 text-base leading-relaxed text-white/80"><%= booster.description %></p>
          <% end %>
        </div>
      </article>
      <% if index < @boosters.size - 1 %>
        <hr class="border-t-2 border-amber-400/40" />
      <% end %>
    <% end %>
  </div>
<% else %>
  <div class="flex min-h-[40vh] flex-col items-center justify-center rounded-2xl border border-white/10 bg-white/5 px-6 text-center">
    <p class="text-lg font-semibold text-white">No boosters listed yet.</p>
  </div>
<% end %>
```



### Navigation: Update `app/views/shared/_navigation.html.erb`
Add gated links in both desktop and mobile nav sections:
```erb
<% if @school&.staff_enabled? %>
  <%= link_to "Our Staff", staff_members_path, class: "..." %>
<% end %>
<% if @school&.photo_gallery_enabled? %>
  <%= link_to "Photos", galleries_path, class: "..." %>
<% end %>
<% if @school&.fundraisers_enabled? %>
  <%= link_to "Fundraisers", fundraisers_path, class: "..." %>
<% end %>
<% if @school&.boosters_enabled? %>
  <%= link_to "Our Boosters", boosters_path, class: "..." %>
<% end %>
```

---

## 6. Routes: Update `config/routes.rb`

```ruby
namespace :admin do
  # ... existing routes ...
  resources :staff_members
  resources :boosters
  resources :fundraisers
  resources :galleries
end

# Public routes
resources :staff_members, only: [:index]
resources :boosters, only: [:index]
```

---

## 7. Feature Flags

All features are gated behind school-level boolean feature flags (database columns with `default: false, null: false`):
- `staff_enabled` - Staff management with admin CRUD and public display
- `boosters_enabled` - Booster management and public booster page
- `fundraisers_enabled` - Fundraiser management and listing
- `photo_gallery_enabled` - Photo gallery display

Migration reference:
```ruby
# db/migrate/[timestamp]_add_feature_flags_to_schools.rb
add_column :schools, :boosters_enabled, :boolean, default: false, null: false
add_column :schools, :fundraisers_enabled, :boolean, default: false, null: false
add_column :schools, :photo_gallery_enabled, :boolean, default: false, null: false
```

These flags are:
- Hidden from admin dashboards (intentionally not editable via admin UI for safety)
- Must be enabled directly in the database with `rails console`: `School.first.update(staff_enabled: true)`
- Control visibility in navigation, sidebar, and routes (return 404 if disabled)
- Checked at three levels:
  1. **Navigation**: Links only shown when flags enabled
  2. **Admin Sidebar**: Admin links only shown when flags enabled
  3. **Routes**: Return 404 for public routes, redirect with alert for admin routes when disabled

---

## 8. Staff/Boosters Feature - Implementation Details

### Staff Features
- **Photo support**: Staff members have photos via ActiveStorage, uploaded to S3
- **Photo removal**: Uses `photo_remove == "1"` checkbox with S3 `purge_later`
- **Staff ordering**: By is_band_director DESC, then display_order ASC, then name ASC
- **Display order auto-increment**: When creating a new staff member, display_order is automatically set to the count of existing staff for that school
- **Display order field**: Hidden in new form, editable in edit form
- **Program field**: Set to nil (All Programs) by default via controller, not shown in form
- **School field**: Visible in form for selection (important for multi-school support)
- **Featured section**: Band director shown in larger featured section above other staff
- **Photo fallback**: Shows SVG user icon if no photo attached

### Boosters Features
- **No photos**: Boosters are text-only with name, role, and description
- **Unified interface**: Boosters displayed on same page as staff via tabs
- **Booster model**: Pre-existing model with full_name, role, description fields
- **Tab navigation**: Dynamic tabs show "Our Staff" and "Our Boosters" when respective features enabled
- **Active tab**: Set by controller (@active_tab = "boosters" in BoostersController)

### Unified Page Architecture
- **Single template**: `app/views/staff_members/index.html.erb` serves both staff and boosters
- **Dynamic header**: Page header changes based on active_tab (dynamic title, subtitle, badge)
- **Tab system**: Links to /staff_members and /boosters, active state determined by @active_tab or params[:tab]
- **Partial rendering**: 
  - `_staff_members.html.erb` - displays staff with photos and featured director
  - `_boosters.html.erb` - displays boosters as simple text entries
- **Controllers**:
  - StaffMembersController: Default loads staff, optionally loads boosters if enabled, renders staff_members/index
  - BoostersController: Loads both staff and boosters, sets @active_tab = "boosters", renders staff_members/index

### Feature Gating Levels
1. **Navigation links**: Only shown when respective features enabled
2. **Admin sidebar links**: Only shown when respective features enabled  
3. **Routes**: Return 404 for public GET routes when disabled
4. **Admin routes**: Redirect with alert when disabled

### Key Integration Points
- **Admin::ApplicationController**: Sets @school = School.first (required because it inherits from Administrate, not main ApplicationController)
- **Admin sidebar**: Conditional rendering of feature links based on school flag checks
- **Navigation sidebar**: Conditional rendering of public feature links
- **Database**: All feature flags stored on School model as boolean columns with default: false, not null
- **AWS S3 Storage**: Configured in `config/storage.yml` with `root: <%= ENV.fetch("AWS_S3_ROOT", "general") %>` (defaults to "general" folder, configurable via AWS_S3_ROOT environment variable)

### Setup Sequence
1. Create migrations for staff_members table and feature flags
2. Create StaffMember model with associations and validations
3. Create Booster model (likely pre-existing) with full_name method
4. Generate StaffMemberDashboard via Administrate
5. Create Admin::StaffMembersController with permission handling
6. Create public StaffMembersController with feature gate
7. Create public BoostersController with delegation
8. Update Admin::ApplicationController with set_school
9. Create unified staff_members/index.html.erb template
10. Create _staff_members.html.erb and _boosters.html.erb partials
11. Update admin form template with photo field and integer detection
12. Update admin sidebar with conditional feature links
13. Update navigation with conditional feature links
14. Add routes for admin and public access
15. Enable features via rails console as needed
