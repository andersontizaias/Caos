Pod::Spec.new do |s|
  s.name             = 'Caos'
  s.version          = '1.0.0'
  s.summary          = 'Server-Driven UI framework for iOS — build screens from YAML.'
  s.description      = <<-DESC
    Caos (Configurable Automated On-demand Screens) generates iOS UI screens
    dynamically from YAML files. Supports SwiftUI and UIKit with a reactive
    data binding system and MV architecture.
  DESC
  s.homepage         = 'https://github.com/andersontizaias/Caos'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'andersontizaias' => 'andersontizaias@gmail.com' }
  s.source           = { :git => 'https://github.com/andersontizaias/Caos.git', :tag => s.version.to_s }
  s.ios.deployment_target = '16.0'
  s.swift_version = '5.9'
  s.source_files = 'Caos/Classes/**/*'
end
