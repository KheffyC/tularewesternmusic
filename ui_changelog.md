# UI Cleanup & Program Show Page Removal

## Overview
This changelog documents the removal of the individual program show page and the redesign of the programs listing on the about page for improved UX and reduced redundancy.

## Changes Made

### 1. Removed Program Show Page (`/programs/:id`)
- **Deleted:** `app/views/programs/show.html.erb` - Standalone program detail page with PDF uploads, calendar, and program info
- **Route Removed:** `resources :programs, only: [:show]` in `config/routes.rb`
- **Controller Updated:** Removed `show` action from `ProgramsController`
- **Rationale:** The show page was redundant since all program information is already displayed on the about page (`/home/about`). Removing it simplifies navigation and reduces code duplication.

### 2. Programs Index Layout Redesign (about.html.erb)
Transformed from **card-based** to **section-based** layout matching the staff/boosters page pattern.

#### Layout Changes:
- **Before:** Programs displayed in dark rounded cards with shadows and alternating image positions
- **After:** Programs displayed as clean sections with gold dividers between them, consistent image positioning

#### Specific Improvements:
- **Removed:** Card styling (shadows, rounded corners, gradients, overlays)
- **Removed:** Alternating image positions (`sm:order-last` logic)
- **Added:** Gold divider `<hr>` with `border-amber-300` between program sections (except before first)
- **Images:** Consistent positioning on the left side (not alternating)
- **Descriptions:** Display vertically inline with images on the right
- **Container Width:** Constrained to `max-w-7xl` for better readability

#### CSS Classes Changed:
```erb
<!-- Before (card-based) -->
<article class="flex flex-col overflow-hidden bg-neutral-900 shadow-[0_14px_30px_rgba(0,0,0,0.4)] transition duration-300 sm:flex-row">
  <div class="relative h-56 w-full sm:h-64 sm:w-64 lg:h-80 lg:w-80 <%= i.odd? ? 'sm:order-last' : '' %>">
  <div class="flex flex-1 flex-col justify-between gap-4 p-6 sm:p-8 lg:p-10">

<!-- After (section-based) -->
<hr class="border-0 border-t-2 border-amber-300 my-6 lg:my-8" />
<div class="flex flex-col gap-6 sm:flex-row sm:gap-8 lg:gap-10 py-6 lg:py-8">
  <div class="relative h-56 w-full sm:h-64 sm:w-64 lg:h-72 lg:w-72">
  <div class="flex flex-1 flex-col justify-center gap-3">
```

### 3. Home Page Program Cards Refactor (_programs.html.erb)
Fixed broken link and improved card interactivity:

#### Changes:
- **Removed:** `link_to program_path` wrapper causing ActionView::Template::Error
- **Removed:** All hover effects (`group-hover:scale-105`, `-translate-y-1`, shadow transitions) to make cards informational only
- **Added:** "View Class Schedule" button below section subtitle with gold border and rounded corners
  - Links to `/home/about` where users can see full program details
  - Styling: `rounded-lg border border-amber-300 bg-red-700 px-6 py-2`
  - Hover state: `hover:bg-red-800`
- **Result:** Program cards now serve as visual teasers with a clear CTA to the detailed class schedule

### 4. Admin Dashboard Cleanup (program_dashboard.rb)
Removed 5 unused form fields from Program admin edit/new pages:

- `ig_handle` - Was used for Instagram handle in "Stay Connected" section
- `circuit` - Was used for competition circuit display
- `program_support_text` - Was used in "Support This Program" box
- `about_image_url` - Was used for sidebar image
- `calendar_url` - Was used for calendar iframe

**Retained fields:** school, description, name, short_name, period, year_established, hero_title, detailed_description, main_gallery_image_url (all needed for about page display)

### 3. Navigation & Routing Impact
- **No changes needed:** Link from about page no longer connects to a show page (programs are just sections now)
- **Home page unaffected:** Still uses `/home/about` as the primary programs listing

## Benefits

1. **Simpler User Experience:** Users see all programs on one page without clicking through individual cards
2. **Consistent Design Language:** About page now matches staff/boosters section-based layout
3. **Reduced Code:** Eliminated 80+ lines of redundant view, controller action, and route code
4. **Better Readability:** Clean section dividers and consistent image placement improve visual hierarchy
5. **Responsive:** Same mobile-friendly behavior with better spacing

## Files Modified

| File | Action | Notes |
|------|--------|-------|
| `config/routes.rb` | Updated | Removed `:show` from programs resources |
| `app/controllers/programs_controller.rb` | Updated | Removed `show` action |
| `app/views/home/about.html.erb` | Refactored | Converted from cards to sections with dividers |
| `app/dashboards/program_dashboard.rb` | Updated | Removed 5 unused form fields |
| `app/views/programs/show.html.erb` | Deleted | No longer needed |

### Removed Program Dashboard Fields
Since the show page is gone, these fields are no longer necessary in the admin edit/new forms:
- `ig_handle` - Was used for Instagram handle in "Stay Connected" section
- `circuit` - Was used for competition circuit display
- `program_support_text` - Was used in "Support This Program" box
- `about_image_url` - Was used for sidebar image
- `calendar_url` - Was used for calendar iframe

**Retained fields:** school, description, name, short_name, period, year_established, hero_title, detailed_description, main_gallery_image_url (all needed for about page display)

## Design Pattern Consistency

The about page now follows the same design pattern as:
- **Staff page** (`app/views/staff_members/index.html.erb`) - Section-based layout with gold dividers
- **Boosters page** (shares unified template with staff)

This creates visual and UX consistency across the site.
