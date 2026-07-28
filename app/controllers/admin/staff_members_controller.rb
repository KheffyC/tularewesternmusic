module Admin
  class StaffMembersController < Admin::ApplicationController
    before_action :require_staff_enabled!

    def permitted_attributes
      super + [:photo, :photo_remove]
    end

    def update_resource(resource, attribs)
      if attribs["photo_remove"] == "1"
        resource.photo.purge_later if resource.photo.attached?
        attribs.delete("photo_remove")
      end

      super(resource, attribs)
    end

    def create_resource(resource)
      resource.school = @school
      resource.program = nil
      resource.display_order = @school.staff_members.count
      super(resource)
    end

    private

    def require_staff_enabled!
      redirect_to admin_root_path, alert: "Staff feature is not enabled." unless @school&.staff_enabled?
    end
  end
end
