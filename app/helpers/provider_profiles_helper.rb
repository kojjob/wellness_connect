module ProviderProfilesHelper
  def availabilities_data
    return [] unless @provider_profile

    @provider_profile.availabilities
      .where(is_booked: false)
      .where("start_time > ?", Time.current)
      .order(:start_time)
      .map do |avail|
        {
          id: avail.id,
          start_time: avail.start_time.iso8601,
          end_time: avail.end_time.iso8601,
          is_booked: avail.is_booked
        }
      end
  end
end
