# FlickrSearchChallenge

This project is written as a coding challenge.
`FlickrSearchChallenge` is a single view application that can search trough Flickr photos using [Flickr API](https://www.flickr.com/services/api) and then displays the search results in a paginated collection view.
The application was written using Xcode 11.2.1 and Swift 5.1

### How to run
`Simulator`
You should be able to just run the application on the simulator with no problems.
`Device`
To run the application on device you will need to specify the "Development Team" in "Singing & Capabilities" and may be required to change the "Bundle Identifier" in the same tab.

### Overview
* As presentation layer architecture was used MVP. The View is responsible for UI management, Presenter contains the module logic necessary for presentation and the Model persists the business logic and state.
* I didn't write any tests for the View related part of the Search module. There are two ways to cover the logic there with tests: SnapshotsTesting or to create a mediator/ViewModel that will encapsulate the processing of `SearchViewController.State`
* For the image caching I used NSCache. I would like to also cache the images on disk, but this will imply more effort for persisting, invalidating, testing, so I left this for later implementation.
* I wrote everything in application target for now but I'm considering moving the API logic into a separate target and use it as a framework to separate logic, models, tests. This will probably be done later.

### TODOs
* Add a debouncer that will prevent the requests before used finishes typing.
* Adjust ImageCaching with a possibility to save on disc.
* Improve collection layout based on image sizes/orientations.
* Move API logic in a separate target.
* Add nice application icon and launch screen.
* Cover the View part of SearchModule with tests.
