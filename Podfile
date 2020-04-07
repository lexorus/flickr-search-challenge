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
	pod 'MicroNetwork', :git => 'https://github.com/lexorus/MicroNetwork.git', :tag => '0.2.0'

	target 'PhotosAPITests' do
		pod 'MicroNetworkMocks', :git => 'https://github.com/lexorus/MicroNetwork.git', :tag => '0.2.0'
	end
end
