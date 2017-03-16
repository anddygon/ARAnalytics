Pod::Spec.new do |s|
  s.name         =  'ARAnalytics'
  s.version      =  '4.0.1'
  s.license      =  {:type => 'MIT', :file => 'LICENSE' }
  s.homepage     =  'https://github.com/orta/ARAnalytics'
  s.authors      =  { 'orta' => 'orta.therox@gmail.com', 'Daniel Haight' => "confidence.designed@gmail.com" }
  s.source       =  { :git => 'https://github.com/orta/ARAnalytics.git', :tag => s.version.to_s }
  s.ios.deployment_target = "7.0"
  s.social_media_url = "https://twitter.com/orta"
  s.summary      =  'Using subspecs you can define your analytics provider with the same API on iOS.'
  # s.description is at the bottom as it is partially generated.

  appsflyer        = { :spec_name => "AppsFlyer",           :dependency => "AppsFlyerFramework" }
  firebase         = { :spec_name => "Firebase",            :dependency => "Firebase" }

  all_analytics = [appsflyer, firebase]

  # To make the pod spec API cleaner, subspecs are "iOS/KISSmetrics"

  s.subspec "CoreIOS" do |ss|
    ss.source_files = ['*.{h,m}', 'Providers/ARAnalyticalProvider.{h,m}', 'Providers/ARAnalyticsProviders.h']
    ss.exclude_files = ['ARDSL.{h,m}']
    ss.private_header_files = 'ARNavigationControllerDelegateProxy.h'
    ss.ios.deployment_target = '7.0'
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
        sources << "Extensions/*+#{providername}.{h,m}"
      end

      ss.ios.source_files = sources
      ss.dependency 'ARAnalytics/CoreIOS'
      ss.platform = :ios
      all_ios_names << providername

      # If there's a podspec dependency include it
      Array(analytics_spec[:dependency]).each do |dep|
          ss.dependency *dep
      end

    end
  end

  ios_spec_names = all_ios_names[0...-1].join(", ") + " and " + all_ios_names[-1]
  s.description  =  "ARAnalytics is a analytics abstraction library offering a sane API for tracking events and user data. It currently supports on iOS: #{ ios_spec_names }. It does this by using CocoaPods subspecs to let you decide which libraries you'd like to use. You are free to also use the official API for any provider too. Also, comes with an amazing DSL to clear up your methods."

end
