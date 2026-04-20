# File: app/bathroom_os.py

from __future__ import annotations


BATHROOM_STEPS = [
    "Spruzzare ganci + interno wc con prodotto + spazzolare con lo scopino.",
    "Picchiare scopino sui bordi interni + mettere a scolare sotto l’asse.",
    "Anticalcare spray nel lavandino, nel bidet, pareti doccia e pavimento doccia.",
    "Straccio rosa: passare lavandino.",
    "Straccio rosa: passare bidet.",
    "Straccio rosa: passare doccia.",
    "Sciacquare con doccino le pareti della doccia (anche i muri).",
    "Con spruzzino wc spruzzare scopino e metterlo nel bidet.",
    "Con spruzzino sciacquare interno wc + tirare sciacquone.",
    "Con straccio grigio ripassare tutto il wc dentro e fuori + asse + pavimento fondo pavimento.",
    "Con straccio grigio pulire contenitore scopino.",
    "Rimettere scopino nel contenitore.",
    "Straccio rosa: passare tutto il lavandino dentro fuori sopra sotto. Se tanti peli usare carta prima.",
    "Straccio rosa: passare tutto il bidet.",
    "Passare vetri della doccia con tira vetri.",
    "Straccio doccia blu umido: passare vetri e pareti della doccia.",
    "Controllare contro luce pareti vetro doccia.",
    "Passare tiravetri pavimento doccia. Ogni tanto controllare piletta. Se ci sono troppi peli usare carta.",
    "Straccio per asciugare azzurro: asciugare tutto.",
    "Asciugare gabinetto con carta.",
    "Alcool 70% + panno azzurro/verde: passare specchio.",
    "Pulire piedini tavolino di legno e sotto al cestino con carta già usata.",
    "Spruzzare wc con candeggina e lasciarla dentro.",
]


class BathroomOS:
    def __init__(self) -> None:
        self.current_index = 0

    def get_current_step(self) -> str:
        if self.current_index >= len(BATHROOM_STEPS):
            return "Procedura completata."
        return BATHROOM_STEPS[self.current_index]

    def next_step(self) -> str:
        if self.current_index < len(BATHROOM_STEPS):
            self.current_index += 1
        return self.get_current_step()

    def previous_step(self) -> str:
        if self.current_index > 0:
            self.current_index -= 1
        return self.get_current_step()

    def reset_steps(self) -> str:
        self.current_index = 0
        return self.get_current_step()

    def get_progress(self) -> tuple[int, int]:
        current = min(self.current_index + 1, len(BATHROOM_STEPS))
        total = len(BATHROOM_STEPS)
        return current, total

    def is_completed(self) -> bool:
        return self.current_index >= len(BATHROOM_STEPS)


if __name__ == "__main__":
    os_bagno = BathroomOS()

    print("\nBATHROOM OS\n")

    while True:
        current, total = os_bagno.get_progress()
        print(f"\nStep {current}/{total}")
        print(os_bagno.get_current_step())

        if os_bagno.is_completed():
            break

        command = input("\nPremi INVIO per andare avanti, 'b' per tornare indietro, 'r' per reset, 'q' per uscire: ").strip().lower()

        if command == "q":
            break
        elif command == "b":
            os_bagno.previous_step()
        elif command == "r":
            os_bagno.reset_steps()
        else:
            os_bagno.next_step()


# EOF - bathroom_os.py