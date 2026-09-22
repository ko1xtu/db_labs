import sys
import dual_manager
from PyQt6.QtWidgets import (
    QAbstractItemView,
    QApplication,
    QFormLayout,
    QHBoxLayout,
    QHeaderView,
    QLineEdit,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWidget,
)


class DatabaseManager:
    """Delegates all CRUD operations to the unified dual backend (python/C#)."""

    def __init__(self):
        self.backend = dual_manager

    def fetch_parent_records(self) -> list[tuple[int, str]]:
        return self.backend.get_parent_list()

    def filter_records(
        self, text_filter: str, start_date: str, end_date: str
    ) -> list[tuple]:
        del start_date, end_date
        return self.backend.filter_users(text_filter)

    def save_record(
        self, first_name: str, last_name: str, phone: str, id_card: str
    ) -> bool:
        if self.backend.check_exists(id_card):
            return False
        result = self.backend.save_user(first_name, last_name, phone, id_card)
        return result is not None and result > 0

    def delete_record(self, record_id: int) -> tuple[bool, str]:
        return self.backend.delete_user(record_id)


class MainWindow(QMainWindow):

    def __init__(self):
        super().__init__()
        self.db = DatabaseManager()
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle("Управление данными БД")
        self.resize(900, 600)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)

        # ---------------------------------------------------------
        # 1. Filter Section (Выборка и фильтрация)
        # ---------------------------------------------------------
        filter_layout = QHBoxLayout()

        self.filter_input = QLineEdit()
        self.filter_input.setPlaceholderText("Поиск по имени, фамилии или ID-карте...")

        btn_apply_filter = QPushButton("Применить фильтр")
        btn_apply_filter.clicked.connect(self.on_filter)

        filter_layout.addWidget(self.filter_input)
        filter_layout.addWidget(btn_apply_filter)

        main_layout.addLayout(filter_layout)

        # ---------------------------------------------------------
        # 2. Table Section (Отображение данных)
        # ---------------------------------------------------------
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(
            ["ID", "Фамилия", "Имя", "Телефон", "ID-карта"]
        )
        self.table.horizontalHeader().setSectionResizeMode(
            QHeaderView.ResizeMode.Stretch
        )
        self.table.setSelectionBehavior(
            QAbstractItemView.SelectionBehavior.SelectRows
        )
        self.table.setEditTriggers(
            QAbstractItemView.EditTrigger.NoEditTriggers
        )

        main_layout.addWidget(self.table)

        # ---------------------------------------------------------
        # 3. Input Section (Добавление/Редактирование)
        # ---------------------------------------------------------
        form_layout = QFormLayout()

        self.input_first_name = QLineEdit()
        self.input_last_name = QLineEdit()
        self.input_phone = QLineEdit()
        self.input_id_card = QLineEdit()

        form_layout.addRow("Имя:", self.input_first_name)
        form_layout.addRow("Фамилия:", self.input_last_name)
        form_layout.addRow("Телефон:", self.input_phone)
        form_layout.addRow("ID-карта:", self.input_id_card)

        main_layout.addLayout(form_layout)

        # ---------------------------------------------------------
        # 4. Action Buttons (Управление)
        # ---------------------------------------------------------
        actions_layout = QHBoxLayout()

        btn_save = QPushButton("Сохранить запись")
        btn_save.clicked.connect(self.on_save)

        btn_delete = QPushButton("Удалить выбранное")
        btn_delete.clicked.connect(self.on_delete)

        actions_layout.addWidget(btn_save)
        actions_layout.addWidget(btn_delete)

        main_layout.addLayout(actions_layout)

    # ---------------------------------------------------------
    # UI Logic & Event Handlers
    # ---------------------------------------------------------
    def on_filter(self):
        """Handle search filtering execution via database backend."""
        query_text = self.filter_input.text().strip()

        results = self.db.filter_records(query_text, "", "")
        self.render_table_data(results)

        if not results:
            QMessageBox.information(self, "Поиск", "Такой записи нет")

    def on_save(self):
        """Validate input and trigger PL/pgSQL save operation."""
        first_name = self.input_first_name.text().strip()
        last_name = self.input_last_name.text().strip()
        phone = self.input_phone.text().strip()
        id_card = self.input_id_card.text().strip()

        if not first_name or not last_name or not phone or not id_card:
            QMessageBox.warning(
                self, "Ошибка ввода", "Все поля должны быть заполнены."
            )
            return

        # Execute backend logic (checks duplicates before insert)
        success = self.db.save_record(first_name, last_name, phone, id_card)

        if success:
            QMessageBox.information(
                self, "Успех", "Запись успешно сохранена."
            )
            self.on_filter()  # Refresh table
        else:
            QMessageBox.critical(
                self,
                "Ошибка",
                "Запись с таким ID-карты уже существует или произошла ошибка записи.",
            )

    def on_delete(self):
        """Prompt confirmation and execute backend delete operation."""
        selected_rows = self.table.selectionModel().selectedRows()

        if not selected_rows:
            QMessageBox.warning(
                self,
                "Предупреждение",
                "Выберите строку для удаления из таблицы.",
            )
            return

        row_index = selected_rows[0].row()
        record_id = int(self.table.item(row_index, 0).text())

        # Deletion confirmation prompt requirement
        reply = QMessageBox.question(
            self,
            "Подтверждение удаления",
            "Вы действительно уверены?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            QMessageBox.StandardButton.No,
        )

        if reply == QMessageBox.StandardButton.Yes:
            success, error = self.db.delete_record(record_id)
            if success:
                QMessageBox.information(
                    self, "Успех", "Запись успешно удалена."
                )
                self.on_filter()  # Refresh table
            else:
                QMessageBox.critical(
                    self, "Ошибка", f"Не удалось удалить запись: {error or 'неизвестная ошибка'}"
                )

    def render_table_data(self, records: list[tuple]):
        """Render records array into QTableWidget rows."""
        self.table.setRowCount(0)
        for row_idx, row_data in enumerate(records):
            self.table.insertRow(row_idx)
            for col_idx, value in enumerate(row_data):
                self.table.setItem(
                    row_idx, col_idx, QTableWidgetItem(str(value))
                )


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())