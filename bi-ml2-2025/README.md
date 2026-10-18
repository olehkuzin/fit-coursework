# BI-ML2: machine learning 2 (summer 2024/25, B242)

Both homeworks use greyscale images derived from the
[Fashion-MNIST dataset](https://www.kaggle.com/datasets/zalando-research/fashionmnist).

| Folder | Task | Data expected next to the notebook |
|---|---|---|
| [`hw01-dimensionality-reduction/`](hw01-dimensionality-reduction/) | Homework 1: dimensionality reduction and binary classification (SVM, naive Bayes, LDA) on 28×28 images | `train.csv`, `evaluate.csv` |
| [`hw02-neural-networks/`](hw02-neural-networks/) | Homework 2: neural networks in PyTorch on 32×32 images, comparing architectures and optimizers | `train.csv`, `evaluate.csv` |

Not included: the course datasets (`train.csv` is ~130 MB), the prediction outputs, and the
trained `.pt` model checkpoints. The notebook writes checkpoints to `models/` (create it with `mkdir models` first); the folder is git-ignored.

**Packages:** pandas, numpy, scikit-learn, matplotlib, seaborn, torch, torchvision, tqdm.
