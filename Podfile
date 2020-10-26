install! 'cocoapods',
	:preserve_pod_file_structure => true,
	:generate_multiple_pod_projects => true,
	:incremental_installation => true

platform :ios, '10.0'
use_frameworks!

target 'FlickrSearch' do
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
    pod 'RxDataSources', '~> 4.0'

	target 'FlickrSearchTests' do
		inherit! :search_paths

	    pod 'RxBlocking', '~> 5'
	    pod 'RxTest', '~> 5'
	end
end

target 'PhotosAPI' do
	pod 'Sourcery'
	pod 'MicroNetwork', :git => 'https://github.com/lexorus/MicroNetwork.git', :tag => '0.3.0'

	target 'PhotosAPITests' do
		pod 'MicroNetworkMocks', :git => 'https://github.com/lexorus/MicroNetwork.git', :tag => '0.3.0'
	end
end
