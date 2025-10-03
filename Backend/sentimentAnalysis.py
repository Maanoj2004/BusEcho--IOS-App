import sys
import json
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

def get_sentiment_rating(text):
    analyzer = SentimentIntensityAnalyzer()
    score = analyzer.polarity_scores(text)["compound"]

    if score >= 0.5:
        return 5
    elif score >= 0.2:
        return 4
    elif score >= -0.2:
        return 3
    elif score >= -0.5:
        return 2
    else:
        return 1

def analyze_star_ratings(punctuality, cleanliness, comfort, staff_behaviour):
    ratings = [punctuality, cleanliness, comfort, staff_behaviour]
    avg = sum(ratings) / len(ratings)

    if avg >= 4.5:
        interpretation = "Excellent"
    elif avg >= 4.0:
        interpretation = "Very Good"
    elif avg >= 3.0:
        interpretation = "Good"
    elif avg >= 2.0:
        interpretation = "Fair"
    elif avg >= 1.0:
        interpretation = "Poor"
    else:
        interpretation = "Very Poor"

    return round(avg, 1), interpretation

# Read JSON from PHP
input_data = sys.stdin.read()
data = json.loads(input_data)

review_text = data.get("review_text", "")
punctuality = int(data.get("punctuality", 0))
cleanliness = int(data.get("cleanliness", 0))
comfort = int(data.get("comfort", 0))
staff_behaviour = int(data.get("staff_behaviour", 0))

# Analyze both
sentiment_rating = get_sentiment_rating(review_text)
star_rating_avg, interpretation = analyze_star_ratings(punctuality, cleanliness, comfort, staff_behaviour)

# Weighted overall: 70% stars + 30% sentiment
overall_rating = round((0.7 * star_rating_avg + 0.3 * sentiment_rating), 1)

# Return result to PHP
print(json.dumps({
    "sentiment_rating": sentiment_rating,
    "star_rating_avg": star_rating_avg,
    "star_rating_interpretation": interpretation,
    "overall_rating": overall_rating
}))
