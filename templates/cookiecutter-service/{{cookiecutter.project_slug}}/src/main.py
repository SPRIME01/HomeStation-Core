"""Entry point for {{cookiecutter.project_slug}}."""

import uvicorn
from fastapi import FastAPI

app = FastAPI(title="{{cookiecutter.project_slug}} API")

@app.get("/")
async def root():
    return {"msg": "Hello, world!"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
