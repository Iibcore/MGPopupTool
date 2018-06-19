Pod::Spec.new do |s|
    s.name         = 'MGPopupTool'
    s.version      = '1.0.0'
    s.summary      = 'MGPopupTool 是一种视图弹出工具，为 自定义的 UIView 提供 Alert 和 ActionSheet 两种弹出模式。'
    s.homepage     = 'https://github.com/Iibcore/MGPopupTool'
    s.license      = 'MIT'
    s.authors      = {'Luqiang' => 'china.zhangluqiang@gmail.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/Iibcore/MGPopupTool.git', :tag => s.version}
    s.source_files = 'MGPopupTool/**/*.{h,m}'
    s.requires_arc = true
end
