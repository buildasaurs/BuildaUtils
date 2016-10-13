Pod::Spec.new do |s|

  s.name         = "BuildaUtils"
  s.version      = "0.3.2"
  s.summary      = "Shared utilities for the Buildasaur and XcodeServerSDK projects."

  s.description  = <<-DESC
                   Both Buildasaur and XcodeServerSDK need similar utilities. This is where I keep them.
                   DESC

  s.homepage     = "https://github.com/buildasaurs/BuildaUtils"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.author             = { "Honza Dvorsky" => "http://honzadvorsky.com" }
  
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/buildasaurs/BuildaUtils.git", :tag => "v#{s.version}" }
  s.source_files  = "Source/*.{swift}"

  # load the dependencies from the podfile for target ekgclient
  podfile_deps = Podfile.from_file(Dir["Podfile"].first).target_definitions["BuildaUtils"].dependencies
  podfile_deps.each do |dep|
    s.dependency dep.name, dep.requirement.to_s
  end

end
