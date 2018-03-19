Geocoder.configure(lookup: :test)

Geocoder::Lookup::Test.add_stub(
  'Rosario, Argentina', [
    {
      'coordinates'  => [-32.9442426, -60.65053880000001],
      'address'      => 'Rosario, Santa Fe Province, Argentina',
      'state'        => 'Rosario',
      'state_code'   => 'Rosario',
      'country'      => 'Argentina',
      'country_code' => 'AR'
    }
  ]
)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates'  => [37.3318598, -122.0302485],
      'address'      => 'Infinite Loop 1, 1 Infinite Loop, Cupertino, CA 95014, USA',
      'state'        => 'California',
      'state_code'   => 'CA',
      'postal_code'  => '95014',
      'country'      => 'United States',
      'country_code' => 'USA'
    }
  ]
)
