Pod::Spec.new do |s|
  s.name         =  'ARAnalytics'
  s.version      =  '4.0.7'
  s.license      =  {:type => 'MIT', :file => 'LICENSE' }
  s.homepage     =  'https://github.com/orta/ARAnalytics'
  s.authors      =  { 'orta' => 'orta.therox@gmail.com', 'Daniel Haight' => "confidence.designed@gmail.com" }
  s.source       =  { :git => 'https://github.com/orta/ARAnalytics.git', :tag => s.version.to_s }
  s.ios.deployment_target = "7.0"
  s.social_media_url = "https://twitter.com/orta"
  s.summary      =  'Using subspecs you can define your analytics provider with the same API on iOS.'
  # s.description is at the bottom as it is partially generated.

  appsflyer        = { :spec_name => "AppsFlyer",           :vendored_frameworks => "AppsFlyerFramework-4.7.2/AppsFlyerLib.framework" }
  firebase         = { :spec_name => "Firebase",            :dependency => "Firebase" }
  google           = { :spec_name => "GoogleAnalytics", :vendored_libraries => "GoogleAnalytics-3.17.0/Libraries/libGoogleAnalytics.a", :source_files => "GoogleAnalytics-3.17.0/Sources/*.h", :frameworks => [
    "CoreData",
    "SystemConfiguration"
  ],
  :libraries => [
    "z",
    "sqlite3"
  ],       :has_extension => true }
  dumplings         = { :spec_name => "Dumplings", :vendored_frameworks => "DumplingsTracker-1.1.0/DumplingsTracker.framework" }
  # dumplings         = { :spec_name => "Dumplings", :source_files => "DumplingsTracker/*.{h,m}", :requires_arc => false }
  facebook          = { :spec_name => "Facebook", :dependency => "FBSDKCoreKit" }
  criteo            = { :spec_name => "Criteo", :dependency => "CriteoEventsSDK" }

  all_analytics = [appsflyer, firebase, google, dumplings, facebook, criteo]
  spec_keys = [:dependency, :source, :source_files, :vendored_libraries, :frameworks, :libraries]

  # To make the pod spec API cleaner, subspecs are "iOS/KISSmetrics"

  s.subspec "CoreIOS" do |ss|
    ss.source_files = ['*.{h,m}', 'Providers/ARAnalyticalProvider.{h,m}', 'Providers/ARAnalyticsProviders.h']
    ss.exclude_files = ['ARDSL.{h,m}']
    ss.private_header_files = 'ARNavigationControllerDelegateProxy.h'
    ss.ios.deployment_target = '7.0'
    ss.frameworks = 'UIKit'
  end

  # s.subspec "DSL" do |ss|
  #   ss.source_files = ['ARDSL.{h,m}']
  #   ss.dependency 'RSSwizzle', '~> 0.1.0'
  #   ss.dependency 'ReactiveCocoa', '~> 2.0'
  # end

  # for the description
  all_ios_names = []

  # make specs for each analytics
  all_analytics.each do |analytics_spec|
    s.subspec analytics_spec[:spec_name] do |ss|

      if analytics_spec[:ios_deployment_target]
        ss.ios.deployment_target = analytics_spec[:ios_deployment_target]
      end

      providername = analytics_spec[:provider]? analytics_spec[:provider] : analytics_spec[:spec_name]

      # Each subspec adds a compiler flag saying that the spec was included
      ss.prefix_header_contents = "#define AR_#{providername.upcase}_EXISTS 1"
      sources = ["Providers/#{providername}Provider.{h,m}"]

      # It there's a category adding extra class methods to ARAnalytics
      if analytics_spec[:has_extension]
        sources << "Extensions/*+#{providername}.{h,m,swift}"
      end

      ss.ios.source_files = sources
      
      ss.dependency 'ARAnalytics/CoreIOS'
      ss.platform = :ios
      all_ios_names << providername

      # If there's a podspec dependency include it
      Array(analytics_spec[:dependency]).each do |dep|
          ss.dependency *dep
      end

      if analytics_spec[:vendored_frameworks]
        ss.vendored_frameworks = analytics_spec[:vendored_frameworks]
      end

      if analytics_spec[:vendored_libraries]
        ss.vendored_libraries = analytics_spec[:vendored_libraries]
      end

      if analytics_spec[:requires_arc]
        ss.requires_arc = analytics_spec[:requires_arc]
	ss.complier_flags = '-fno-objc-arc'
      end

      if analytics_spec[:source]
        ss.source = analytics_spec[:source]
      end

      if analytics_spec[:source_files]
        ss.source_files = analytics_spec[:source_files]
      end

      if analytics_spec[:frameworks]
        ss.frameworks = analytics_spec[:frameworks]
      end

      if analytics_spec[:libraries]
        ss.libraries = analytics_spec[:libraries]
      end

    end
  end

  ios_spec_names = all_ios_names[0...-1].join(", ") + " and " + all_ios_names[-1]
  s.description  =  "ARAnalytics is a analytics abstraction library offering a sane API for tracking events and user data. It currently supports on iOS: #{ ios_spec_names }. It does this by using CocoaPods subspecs to let you decide which libraries you'd like to use. You are free to also use the official API for any provider too. Also, comes with an amazing DSL to clear up your methods."

end
