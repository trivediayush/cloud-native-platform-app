from flask import Flask

app = Flask(__name__)

@app.get("/")
def home():
    return{
        "application": "cloud-native-platform-app",
        "status": "running",
        "version": "1.0.0"
    }

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)