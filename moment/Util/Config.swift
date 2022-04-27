import Foundation

class Config {

    public static let unsplashApiHost = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_HOST") as! String
    public static let unsplashAccessKey = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as! String
    public static let unsplashFetchCount = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_PHOTOS_COUNT") as! String

}
