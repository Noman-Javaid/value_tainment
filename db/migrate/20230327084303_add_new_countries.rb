class AddNewCountries < ActiveRecord::Migration[6.1]
  def change

    countries = [
      { name: 'Australia', alpha2_code: 'AU', phone_code: 61, active: true },
      { name: 'Austria', alpha2_code: 'AT', phone_code: 43, active: true },
      { name: 'Belgium', alpha2_code: 'BE', phone_code: 32, active: true },
      { name: 'Bulgaria', alpha2_code: 'BG', phone_code: 359, active: true },
      { name: 'Croatia', alpha2_code: 'HR', phone_code: 385, active: true },
      { name: 'Cyprus', alpha2_code: 'CY', phone_code: 357, active: true },
      { name: 'Czech Republic', alpha2_code: 'CZ', phone_code: 420, active: true },
      { name: 'Denmark', alpha2_code: 'DK', phone_code: 45, active: true },
      { name: 'Estonia', alpha2_code: 'EE', phone_code: 372, active: true },
      { name: 'Finland', alpha2_code: 'FI', phone_code: 358, active: true },
      { name: 'France', alpha2_code: 'FR', phone_code: 33, active: true },
      { name: 'Germany', alpha2_code: 'DE', phone_code: 49, active: true },
      { name: 'Gibraltar', alpha2_code: 'GI', phone_code: 350, active: true },
      { name: 'Greece', alpha2_code: 'GR', phone_code: 30, active: true },
      { name: 'Hong Kong SAR China', alpha2_code: 'HK', phone_code: 852, active: true },
      { name: 'Hungary', alpha2_code: 'HU', phone_code: 36, active: true },
      { name: 'Ireland', alpha2_code: 'IE', phone_code: 353, active: true },
      { name: 'Italy', alpha2_code: 'IT', phone_code: 39, active: true },
      { name: 'Japan', alpha2_code: 'JP', phone_code: 81, active: true },
      { name: 'Latvia', alpha2_code: 'LV', phone_code: 371, active: true },
      { name: 'Liechtenstein', alpha2_code: 'LI', phone_code: 423, active: true },
      { name: 'Lithuania', alpha2_code: 'LT', phone_code: 370, active: true },
      { name: 'Luxembourg', alpha2_code: 'LU', phone_code: 352, active: true },
      { name: 'Malta', alpha2_code: 'MT', phone_code: 356, active: true },
      { name: 'Mexico', alpha2_code: 'MX', phone_code: 52, active: true },
      { name: 'Netherlands', alpha2_code: 'NL', phone_code: 31, active: true },
      { name: 'New Zealand', alpha2_code: 'NZ', phone_code: 64, active: true },
      { name: 'Norway', alpha2_code: 'NO', phone_code: 47, active: true },
      { name: 'Poland', alpha2_code: 'PL', phone_code: 48, active: true },
      { name: 'Portugal', alpha2_code: 'PT', phone_code: 351, active: true },
      { name: 'Romania', alpha2_code: 'RO', phone_code: 40, active: true },
      { name: 'Singapore', alpha2_code: 'SG', phone_code: 65, active: true },
      { name: 'Slovakia', alpha2_code: 'SK', phone_code: 421, active: true },
      { name: 'Slovenia', alpha2_code: 'SI', phone_code: 386, active: true },
      { name: 'Spain', alpha2_code: 'ES', phone_code: 34, active: true },
      { name: 'Sweden', alpha2_code: 'SE', phone_code: 46, active: true },
      { name: 'Switzerland', alpha2_code: 'CH', phone_code: 41, active: true },
      { name: 'Thailand', alpha2_code: 'TH', phone_code: 66, active: true },
      { name: 'United Arab Emirates', alpha2_code: 'AE', phone_code: 971, active: true },
      { name: 'United Kingdom', alpha2_code: 'GB', phone_code: 44, active: true }
    ]

    countries.each do |country|
      Territory.create(country)
    end
  end
end
