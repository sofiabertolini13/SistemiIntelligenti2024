import tkinter as tk
import minizinc
from tkinter import ttk
from sympy import solve
import os

# Funzione per risolvere il problema MiniZinc
def risolvi_minizinc():

    # Leggi i valori inseriti dall'utente nei campi di testo
    numeroStudenti = [int(studenti1A.get()), int(studenti1B.get())]

    # Carica il modello MiniZinc
    print("Directory corrente:", os.getcwd())
    modello = minizinc.Model(r"C:\Users\SOFIA\OneDrive - unibs.it\Desktop\Progetto Sistemi Intelligenti\Minizinc - Pianificazione orario scolastico.mzn")
    
    # Crea un'istanza del modello
    istanza = minizinc.Instance(minizinc.Solver.lookup("chuffed"), modello)
    istanza["numeroStudenti"] = numeroStudenti

    # Risolvi il problema
    soluzione = istanza.solve()

    # Visualizza i risultati nell'interfaccia grafica
    areaTesto.config(state = "normal")
    areaTesto.delete(1.0, tk.END)
    areaTesto.insert(tk.END, soluzione)
    areaTesto.configure(state = "disabled")

def validate_input(text):
    if text.isdigit() and 1 <= int(text) <= 39:
        return True
    else:
        return False

# Crea l'interfaccia grafica
root = tk.Tk()
root.title("Orario delle lezioni")

# Etichette e campi di testo per inserire i numeri degli studenti delle due classi
messaggioCampiTesto = ttk.Label(root, text = "Inserisci il numero di studenti delle due classi (compresi tra 0 e 40, esclusi)")
messaggioCampiTesto.pack()

etichettaA = ttk.Label(root, text = "Studenti classe 1A:")
etichettaA.pack()
studenti1A = ttk.Entry(root, validate="key")
studenti1A.pack()
studenti1A['validatecommand'] = (studenti1A.register(validate_input), '%P')

etichettaB = ttk.Label(root, text="Studenti classe 1B:")
etichettaB.pack()
studenti1B = ttk.Entry(root, validate="key")
studenti1B.pack()
studenti1B['validatecommand'] = (studenti1B.register(validate_input), '%P')

# Bottone per avviare la risoluzione del modello minizinc
bottone = ttk.Button(root, text = "Calcola orario delle lezioni e l'occupazione delle aule", command=risolvi_minizinc)
bottone.pack()

# Area di testo per visualizzare gli orari delle classi e le occupazioni delle aule
areaTesto = tk.Text(root, height = 35, width = 100, bg = "light yellow")
areaTesto.pack()

root.mainloop()