Pod::Spec.new do |s|
    s.name         = 'RealMadridCFResourcesPod'
    s.version      = '1.0'
    s.summary      = 'Resources for RealMadridCF Target in CustomizationArchitectureDemo project'
    s.homepage	   = 'https://github.com/'
	s.license      = 'MIT'
	s.source       = { :git => 'https://github.com/bgonzalezjurado/RealMadridCFResourcesPod.git', :tag => '' }
    s.author       = { 'bgonzalezjurado' => '' }
    s.platform     = :ios, '9.3'
    s.requires_arc = true
    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
    s.source_files  = 'Classes/*.swift'
    s.resource_bundle = { 'RealMadridCFResourcesPod' => ['**/*.{mp3,ttf,jpg,png,plist,3gp,json}'] }
end