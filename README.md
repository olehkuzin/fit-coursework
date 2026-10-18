# FIT CTU coursework

My homework solutions from courses at the Faculty of Information Technology,
Czech Technical University in Prague (FIT ČVUT), 2024–2025. Each course has its own folder
and README.

| Folder | Course | Semester | Contents |
|---|---|---|---|
| [`bi-ml1-2024/`](bi-ml1-2024/) | BI-ML1, machine learning 1 | 2024/25 | Titanic survival classification (decision tree, KNN), life-expectancy regression with an own random forest implementation |
| [`bi-ml2-2025/`](bi-ml2-2025/) | BI-ML2, machine learning 2 | 2024/25 summer (B242) | Fashion-MNIST: dimensionality reduction + SVM / naive Bayes / LDA; neural networks in PyTorch |
| [`bi-viz-2024/`](bi-viz-2024/) | BI-VIZ, data visualisation | 2024/25 | Exploratory analysis of Austin Animal Center data; network analysis of Prague public transport (PID) |
| [`bi-zns-2025/`](bi-zns-2025/) | BI-ZNS, knowledge systems | 2025/26 | Forward-chaining rule base, Prolog agent (FITYard), fuzzy expert system, rule extraction from a random forest |

## Tech stack

Python 3, Jupyter, pandas, NumPy, scikit-learn, matplotlib/seaborn, PyTorch (BI-ML2),
NetworkX (BI-VIZ), `fuzzy-expert` (BI-ZNS), SWI-Prolog (BI-ZNS).

## Setup

```sh
python3 -m venv .venv && source .venv/bin/activate
pip install jupyter pandas numpy scikit-learn matplotlib seaborn
jupyter lab
```

Extra packages per course are listed in each course README.

## Data

**No datasets or trained models are included.** The notebooks expect the course-provided
files (e.g. `data.csv`, `train.csv`) next to the notebook. Each course README names the
files and their public origin where it is known.

## Screenshots

<!-- TODO: add screenshots of selected plots -->

## License

My own code is under the [MIT license](LICENSE). The assignment texts embedded in the
notebooks (the Czech "Zadání" / "Pokyny k vypracování" sections) and the datasets belong to
FIT ČVUT and their respective owners, and are **not** covered by the MIT license.
