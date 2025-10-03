import Foundation

struct API {
    
    // MARK: - Base URL
    static let baseURL = "http://localhost/busreview/"
    
    // MARK: - Endpoints
    struct Endpoints {
        static let busReview = baseURL + "bus_reviews.php"
        static let userLogin = baseURL + "login.php"
        static let userRegister = baseURL + "signup.php"
        static let sendMailOTP = baseURL + "sendOTP.php"
        static let verifyEmail = baseURL + "verify_mail_otp.php"
        static let editProfile = baseURL + "edit_profile.php"
        static let addbus = baseURL + "addBus.php"
        static let busOperator = baseURL + "bus_operator.php"
        static let buses = baseURL + "buses.php"
        static let busSearch = baseURL + "busSearch.php"
        static let deletProfile = baseURL + "delete_profile_otp.php"
        static let fetchBuses = baseURL + "fetch_buses.php"
        static let fetchComments = baseURL + "fetch_comments.php"
        static let fetchreviews = baseURL + "fetch_reviews.php"
        static let forgotPassword = baseURL + "forgot_password.php"
        static let locations = baseURL + "locations.php"
        static let profileOTP = baseURL + "otp_verify_profile.php"
        static let deleteOTP = baseURL + "otp_verify_delete.php"
        static let dashboardStats = baseURL+"dashboard_stats.php"
        static let commentReviews = baseURL+"comment_reviews.php"
        static let rateApp = baseURL+"rateUs.php"
        static let userProfile = baseURL+"user_profile.php"
        static let resetPassword = baseURL+"resetpassword.php"
        static let likeReviews = baseURL+"like_review.php"
        static let notifications = baseURL+"notifications.php"
    }
}

