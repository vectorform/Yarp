Pod::Spec.new do |s|
  s.name             = "Yarp"
  s.version          = "0.1.0"
  s.summary          = "Yarp (Yet another reachability pod) is a reachability framework with a focus on reliability and simplicity."

  s.description      = <<-DESC
Yarp (Yet another reachability pod) is a reachability framework with a focus on reliability and simplicity. Yarp fully supports IPv6 and IPv4. Yarp allows you to observer changes in reachability using blocks or notifications.
                        DESC

  s.homepage         = "https://github.com/vectorform/Yarp"
  s.license          = 'BSD' #{:type => "BSD", :file => "LICENSE"}
  s.author           = { "Vectorform" => "jmeador@vectorform.com" }
  s.source           = { :git => "https://github.com/vectorform/Yarp.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vectorform'

  s.source_files = 'Core/*.swift'
  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.frameworks = 'SystemConfiguration'

end
