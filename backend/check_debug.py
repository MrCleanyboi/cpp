import sys
with open('debug_out.txt', 'w') as f:
    f.write(f"Python executable: {sys.executable}\n")
    try:
        import torch
        f.write(f"Torch version: {torch.__version__}\n")
    except ImportError as e:
        f.write(f"Torch import failed: {e}\n")

    try:
        import tensorflow as tf
        f.write(f"TensorFlow version: {tf.__version__}\n")
    except ImportError as e:
        f.write(f"TensorFlow import failed: {e}\n")

    try:
        from transformers import pipeline
        f.write("Transformers pipeline imported successfully\n")
    except Exception as e:
        f.write(f"Transformers import failed: {e}\n")

    try:
        import whisper
        f.write(f"Whisper imported successfully\n")
    except ImportError as e:
        f.write(f"Whisper import failed: {e}\n")
