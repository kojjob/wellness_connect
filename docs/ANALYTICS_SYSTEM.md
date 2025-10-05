# Analytics System Documentation

## Overview

The WellnessConnect Analytics System provides comprehensive analytics capabilities for providers, patients, and platform administrators. Built using Rails ActiveSupport::Concern pattern, the system offers modular, reusable analytics functionality across the application.

## Architecture

The analytics system is organized into four core modules, all contained within `app/models/concerns/analytics.rb`:

1. **Analytics::ProviderRevenue** - Revenue tracking and analysis for service providers
2. **Analytics::ProviderAppointments** - Appointment metrics and trends for providers
3. **Analytics::PatientAnalytics** - Client spending and session analytics
4. **Analytics::PlatformAnalytics** - Platform-wide metrics and top performers (class methods)

## Module Descriptions

### 1. Analytics::ProviderRevenue

Provides revenue tracking and financial analytics for service providers.

#### Available Methods

**`total_revenue`**
- **Returns**: Integer (total revenue in cents from all successful payments)
- **Example**: `@provider.total_revenue #=> 150000` ($1,500.00)

**`revenue_for_period(start_date, end_date)`**
- **Parameters**:
  - `start_date` - Beginning of date range
  - `end_date` - End of date range
- **Returns**: Integer (revenue in cents for specified period)
- **Example**:
```ruby
last_month = @provider.revenue_for_period(1.month.ago, Time.current)
#=> 50000 ($500.00)
```

**`revenue_by_month(months = 6)`**
- **Parameters**: `months` - Number of months to analyze (default: 6)
- **Returns**: Hash - Month names as keys, revenue amounts as values
- **Example**:
```ruby
@provider.revenue_by_month(3)
#=> {
#     "January 2024" => 25000,
#     "February 2024" => 30000,
#     "March 2024" => 35000
#   }
```

**`revenue_by_service`**
- **Returns**: Hash - Service names as keys, revenue amounts as values
- **Example**:
```ruby
@provider.revenue_by_service
#=> {
#     "60-Minute Coaching Session" => 120000,
#     "30-Minute Consultation" => 30000
#   }
```

**`average_revenue_per_appointment`**
- **Returns**: Float (average revenue per completed appointment)
- **Safety**: Returns 0.0 if no completed appointments
- **Example**: `@provider.average_revenue_per_appointment #=> 85.50`

### 2. Analytics::ProviderAppointments

Tracks appointment metrics, trends, and patterns for service providers.

#### Available Methods

**`total_appointments_count`**
- **Returns**: Integer (total appointments across all statuses)
- **Example**: `@provider.total_appointments_count #=> 42`

**`completed_appointments_count`**
- **Returns**: Integer (appointments with 'completed' status)

**`cancelled_appointments_count`**
- **Returns**: Integer (appointments cancelled by either party)

**`no_show_appointments_count`**
- **Returns**: Integer (appointments marked as no-show)

**`completion_rate`**
- **Returns**: Float (percentage of appointments completed)
- **Safety**: Returns 0.0 if no appointments
- **Example**: `@provider.completion_rate #=> 85.5`

**`cancellation_rate`**
- **Returns**: Float (percentage of appointments cancelled)
- **Example**: `@provider.cancellation_rate #=> 10.2`

**`no_show_rate`**
- **Returns**: Float (percentage of appointments with no-show)
- **Example**: `@provider.no_show_rate #=> 4.3`

**`appointments_by_month(months = 6)`**
- **Parameters**: `months` - Number of months to analyze
- **Returns**: Hash - Month names as keys, appointment counts as values
- **Example**:
```ruby
@provider.appointments_by_month(3)
#=> {
#     "January 2024" => 12,
#     "February 2024" => 15,
#     "March 2024" => 18
#   }
```

**`appointments_by_status`**
- **Returns**: Hash - Status names as keys, counts as values
- **Example**:
```ruby
@provider.appointments_by_status
#=> {
#     "scheduled" => 5,
#     "completed" => 30,
#     "cancelled_by_patient" => 3,
#     "cancelled_by_provider" => 2,
#     "no_show" => 2
#   }
```

**`peak_booking_hours(limit = 5)`**
- **Parameters**: `limit` - Number of top hours to return (default: 5)
- **Returns**: Hash - Hours as keys (0-23), booking counts as values
- **Example**:
```ruby
@provider.peak_booking_hours(3)
#=> {
#     14 => 8,  # 2:00 PM
#     10 => 7,  # 10:00 AM
#     16 => 6   # 4:00 PM
#   }
```

**`average_appointments_per_week`**
- **Returns**: Float (average weekly appointment count)
- **Calculation**: Based on provider's tenure on platform
- **Example**: `@provider.average_appointments_per_week #=> 3.5`

### 3. Analytics::PatientAnalytics

Provides spending and session analytics for clients.

#### Available Methods

**`total_spent`**
- **Returns**: Integer (total amount spent in cents)
- **Example**: `@patient.total_spent #=> 75000` ($750.00)

**`spending_by_month(months = 6)`**
- **Parameters**: `months` - Number of months to analyze
- **Returns**: Hash - Month names as keys, spending amounts as values
- **Example**:
```ruby
@patient.spending_by_month(3)
#=> {
#     "January 2024" => 15000,
#     "February 2024" => 20000,
#     "March 2024" => 25000
#   }
```

**`total_sessions_count`**
- **Returns**: Integer (total appointments as patient)

**`completed_sessions_count`**
- **Returns**: Integer (completed appointments only)

**`upcoming_sessions_count`**
- **Returns**: Integer (future scheduled appointments)

**`favorite_providers(limit = 5)`**
- **Parameters**: `limit` - Number of providers to return
- **Returns**: Array of hashes with `:provider` and `:sessions` keys
- **Example**:
```ruby
@patient.favorite_providers(3)
#=> [
#     { provider: #<User id: 1>, sessions: 12 },
#     { provider: #<User id: 2>, sessions: 8 },
#     { provider: #<User id: 3>, sessions: 5 }
#   ]
```

**`average_spending_per_session`**
- **Returns**: Float (average amount spent per session)
- **Safety**: Returns 0.0 if no sessions
- **Example**: `@patient.average_spending_per_session #=> 95.50`

### 4. Analytics::PlatformAnalytics

Platform-wide analytics (class methods on User model).

#### Available Methods

**`User.total_users_count`**
- **Returns**: Integer (total users across all roles)

**`User.total_providers_count`**
- **Returns**: Integer (users with provider role)

**`User.total_patients_count`**
- **Returns**: Integer (users with patient role)

**`User.users_growth_by_month(months = 6)`**
- **Parameters**: `months` - Number of months to analyze
- **Returns**: Hash - Month names as keys, new user counts as values
- **Example**:
```ruby
User.users_growth_by_month(3)
#=> {
#     "January 2024" => 45,
#     "February 2024" => 52,
#     "March 2024" => 68
#   }
```

**`User.total_platform_revenue`**
- **Returns**: Integer (total revenue across all providers)

**`User.platform_revenue_by_month(months = 6)`**
- **Parameters**: `months` - Number of months to analyze
- **Returns**: Hash - Month names as keys, revenue amounts as values

**`User.total_appointments_count`**
- **Returns**: Integer (total appointments platform-wide)

**`User.appointments_by_status`**
- **Returns**: Hash - Status names as keys, counts as values
- **Example**:
```ruby
User.appointments_by_status
#=> {
#     "scheduled" => 125,
#     "completed" => 850,
#     "cancelled_by_patient" => 45,
#     "cancelled_by_provider" => 20,
#     "no_show" => 15
#   }
```

**`User.top_providers_by_revenue(limit = 10)`**
- **Parameters**: `limit` - Number of providers to return
- **Returns**: Array of hashes with `:provider` and `:revenue` keys
- **Example**:
```ruby
User.top_providers_by_revenue(5)
#=> [
#     { provider: #<User id: 1>, revenue: 250000 },
#     { provider: #<User id: 2>, revenue: 180000 },
#     ...
#   ]
```

**`User.top_services_by_bookings(limit = 10)`**
- **Parameters**: `limit` - Number of services to return
- **Returns**: Array of hashes with `:service` and `:bookings` keys
- **Example**:
```ruby
User.top_services_by_bookings(5)
#=> [
#     { service: #<Service id: 1>, bookings: 145 },
#     { service: #<Service id: 2>, bookings: 98 },
#     ...
#   ]
```

**`User.average_transaction_value`**
- **Returns**: Float (average payment amount)
- **Safety**: Returns 0.0 if no payments

**`User.payment_success_rate`**
- **Returns**: Float (percentage of successful payments)
- **Safety**: Returns 0.0 if no payments
- **Example**: `User.payment_success_rate #=> 96.5`

## Dashboard Integration Examples

### Provider Dashboard

```erb
<!-- app/views/dashboard/provider_dashboard.html.erb -->

<!-- Revenue Overview -->
<div class="stats-card">
  <h3>Total Revenue</h3>
  <p class="amount"><%= number_to_currency(current_user.total_revenue / 100.0) %></p>
</div>

<!-- Monthly Revenue Trend -->
<div class="chart-container">
  <h3>Revenue by Month</h3>
  <% revenue_data = current_user.revenue_by_month(6) %>
  <% max_revenue = revenue_data.values.max || 1 %>

  <% revenue_data.each do |month, amount| %>
    <div class="chart-bar">
      <span class="month"><%= month %></span>
      <div class="bar" style="width: <%= (amount.to_f / max_revenue * 100) %>%">
        <%= number_to_currency(amount / 100.0) %>
      </div>
    </div>
  <% end %>
</div>

<!-- Appointment Metrics -->
<div class="metrics-grid">
  <div class="metric">
    <h4>Completion Rate</h4>
    <p><%= current_user.completion_rate.round(1) %>%</p>
  </div>

  <div class="metric">
    <h4>Average Revenue/Appointment</h4>
    <p><%= number_to_currency(current_user.average_revenue_per_appointment) %></p>
  </div>

  <div class="metric">
    <h4>Total Appointments</h4>
    <p><%= current_user.total_appointments_count %></p>
  </div>
</div>

<!-- Peak Booking Hours -->
<div class="peak-hours">
  <h3>Your Peak Booking Hours</h3>
  <% current_user.peak_booking_hours(5).each do |hour, count| %>
    <div class="hour-stat">
      <span><%= Time.parse("#{hour}:00").strftime("%I:00 %p") %></span>
      <span><%= count %> bookings</span>
    </div>
  <% end %>
</div>
```

### Patient Dashboard

```erb
<!-- app/views/dashboard/patient_dashboard.html.erb -->

<!-- Spending Overview -->
<div class="stats-card">
  <h3>Total Spent</h3>
  <p class="amount"><%= number_to_currency(current_user.total_spent / 100.0) %></p>
</div>

<!-- Monthly Spending -->
<div class="chart-container">
  <h3>Spending by Month</h3>
  <% spending_data = current_user.spending_by_month(6) %>

  <% spending_data.each do |month, amount| %>
    <div class="spending-bar">
      <span><%= month %></span>
      <span><%= number_to_currency(amount / 100.0) %></span>
    </div>
  <% end %>
</div>

<!-- Session Statistics -->
<div class="session-stats">
  <div class="stat">
    <h4>Completed Sessions</h4>
    <p><%= current_user.completed_sessions_count %></p>
  </div>

  <div class="stat">
    <h4>Upcoming Sessions</h4>
    <p><%= current_user.upcoming_sessions_count %></p>
  </div>

  <div class="stat">
    <h4>Average Cost/Session</h4>
    <p><%= number_to_currency(current_user.average_spending_per_session) %></p>
  </div>
</div>

<!-- Favorite Providers -->
<div class="favorites">
  <h3>Your Most Booked Providers</h3>
  <% current_user.favorite_providers(5).each do |data| %>
    <div class="provider-card">
      <span class="name"><%= data[:provider].full_name %></span>
      <span class="sessions"><%= data[:sessions] %> sessions</span>
    </div>
  <% end %>
</div>
```

### Admin Dashboard

```erb
<!-- app/views/admin/dashboard/index.html.erb -->

<!-- Platform Overview -->
<div class="admin-stats-grid">
  <div class="stat-card">
    <h3>Total Users</h3>
    <p><%= number_with_delimiter(User.total_users_count) %></p>
  </div>

  <div class="stat-card">
    <h3>Total Revenue</h3>
    <p><%= number_to_currency(User.total_platform_revenue / 100.0) %></p>
  </div>

  <div class="stat-card">
    <h3>Payment Success Rate</h3>
    <p><%= User.payment_success_rate.round(1) %>%</p>
  </div>
</div>

<!-- Growth Charts -->
<div class="growth-section">
  <div class="chart">
    <h3>User Growth (Last 6 Months)</h3>
    <% User.users_growth_by_month(6).each do |month, count| %>
      <div class="growth-bar">
        <span><%= month %></span>
        <span><%= count %> new users</span>
      </div>
    <% end %>
  </div>

  <div class="chart">
    <h3>Revenue Growth (Last 6 Months)</h3>
    <% User.platform_revenue_by_month(6).each do |month, revenue| %>
      <div class="revenue-bar">
        <span><%= month %></span>
        <span><%= number_to_currency(revenue / 100.0) %></span>
      </div>
    <% end %>
  </div>
</div>

<!-- Top Performers -->
<div class="top-performers">
  <div class="section">
    <h3>Top Providers by Revenue</h3>
    <% User.top_providers_by_revenue(10).each_with_index do |data, index| %>
      <div class="provider-row">
        <span class="rank">#<%= index + 1 %></span>
        <span class="name"><%= data[:provider].full_name %></span>
        <span class="revenue"><%= number_to_currency(data[:revenue] / 100.0) %></span>
      </div>
    <% end %>
  </div>

  <div class="section">
    <h3>Top Services by Bookings</h3>
    <% User.top_services_by_bookings(10).each_with_index do |data, index| %>
      <div class="service-row">
        <span class="rank">#<%= index + 1 %></span>
        <span class="name"><%= data[:service].name %></span>
        <span class="bookings"><%= data[:bookings] %> bookings</span>
      </div>
    <% end %>
  </div>
</div>
```

## Chart.js Integration

The platform includes a reusable Stimulus controller for Chart.js visualizations:

```erb
<!-- Example: Revenue Chart with Chart.js -->
<canvas
  data-controller="chart"
  data-chart-type-value="bar"
  data-chart-data-value="<%= {
    labels: @revenue_by_month.keys,
    datasets: [{
      label: 'Monthly Revenue',
      data: @revenue_by_month.values.map { |v| v / 100.0 },
      backgroundColor: 'rgba(59, 130, 246, 0.5)',
      borderColor: 'rgb(59, 130, 246)',
      borderWidth: 1
    }]
  }.to_json %>"
  data-chart-options-value="<%= {
    plugins: {
      title: { display: true, text: 'Revenue Trend' }
    }
  }.to_json %>"
></canvas>
```

## Testing

Comprehensive test coverage is available in `test/models/concerns/analytics_test.rb`.

### Running Analytics Tests

```bash
# Run all analytics tests
bin/rails test test/models/concerns/analytics_test.rb

# Run specific test
bin/rails test test/models/concerns/analytics_test.rb:18

# Run with verbose output
bin/rails test test/models/concerns/analytics_test.rb -v
```

### Test Coverage

- **ProviderRevenue**: 7 test cases
- **ProviderAppointments**: 9 test cases
- **PatientAnalytics**: 7 test cases
- **PlatformAnalytics**: 11 test cases
- **Edge Cases**: Zero-division handling, empty data scenarios

### Example Tests

```ruby
# Testing revenue calculation
test "total_revenue returns sum of all successful payments for provider" do
  # Setup test data
  appointment = Appointment.create!(...)
  Payment.create!(payer: @patient, appointment: appointment,
                  amount: 10000, status: :succeeded)

  assert_equal 10000, @provider.total_revenue
end

# Testing edge cases
test "average_revenue_per_appointment returns 0 when no appointments" do
  new_provider = User.create!(role: :provider, ...)
  assert_equal 0, new_provider.average_revenue_per_appointment
end
```

## Performance Considerations

### Database Indexes

Ensure the following indexes exist for optimal performance:

```ruby
# db/migrate/XXX_add_analytics_indexes.rb
add_index :payments, [:payer_id, :status]
add_index :payments, :created_at
add_index :appointments, [:provider_id, :status]
add_index :appointments, [:patient_id, :status]
add_index :appointments, :start_time
```

### Caching Strategies

For expensive calculations, consider caching:

```ruby
# Cache revenue calculation
def cached_total_revenue
  Rails.cache.fetch("provider_#{id}_total_revenue", expires_in: 1.hour) do
    total_revenue
  end
end
```

### Query Optimization

- Use `.includes()` to avoid N+1 queries when displaying provider/service details
- Consider pagination for large datasets (e.g., `User.top_providers_by_revenue(100)`)
- Use database views for complex recurring queries

## Future Enhancements

### Planned Features

1. **Date Range Filtering** (Phase 6, Task 8)
   - Add custom date range selection to all analytics methods
   - Implement date picker UI components

2. **Exportable Reports** (Phase 6, Task 9)
   - CSV export for all analytics data
   - PDF report generation with charts

3. **Real-Time Analytics**
   - WebSocket updates for live dashboard metrics
   - Real-time notifications for milestones

4. **Advanced Visualizations**
   - Interactive Chart.js charts
   - Heatmaps for booking patterns
   - Funnel visualizations for conversion tracking

5. **Comparative Analytics**
   - Compare performance across time periods
   - Benchmark against platform averages
   - Cohort analysis

## Troubleshooting

### Common Issues

**Issue**: Analytics methods return 0 or empty hashes
- **Cause**: No data exists for the specified period or user
- **Solution**: Ensure test/production data exists, check date ranges

**Issue**: Slow analytics queries
- **Cause**: Missing database indexes or large datasets
- **Solution**: Add indexes, implement caching, consider pagination

**Issue**: Incorrect revenue calculations
- **Cause**: Including pending/failed payments in calculations
- **Solution**: Verify only `succeeded` status payments are counted

**Issue**: Division by zero errors
- **Cause**: No appointments exist when calculating averages
- **Solution**: All methods include zero-division guards (returns 0.0)

## Support

For questions or issues with the analytics system:

1. Check this documentation for usage examples
2. Review test files for implementation patterns
3. Consult `app/models/concerns/analytics.rb` for method details
4. Run tests to verify expected behavior

## Changelog

### Version 1.0 (Current)
- Initial analytics system implementation
- Four core modules (ProviderRevenue, ProviderAppointments, PatientAnalytics, PlatformAnalytics)
- Comprehensive test coverage (40+ tests)
- Chart.js integration support
- Provider, patient, and admin dashboard integration
