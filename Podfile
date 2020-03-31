platform :ios, '10.0'
use_frameworks!

target 'FlickrSearch' do
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
end

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
target 'FlickrSearchTests' do
	inherit! :search_paths

    pod 'RxBlocking', '~> 5'
    pod 'RxTest', '~> 5'
end
