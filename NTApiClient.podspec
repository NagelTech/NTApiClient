
Pod::Spec.new do |s|
  s.name         = "NTApiClient"
  s.version      = "0.56"
  s.summary      = "A easy to use API client for IOS development"
  s.homepage     = "https://github.com/NagelTech/NTApiClient"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.authors      = { "Ethan Nagel" => "eanagel@gmail.com", "Jacob Knobel" => "jacobknobel@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/NagelTech/NTApiClient.git", :tag => "v0.56" }
  s.source_files = '*.{h,m}'
  s.platform     = :ios, "6.0"
  s.requires_arc = true
end
