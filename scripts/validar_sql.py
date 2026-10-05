"""Valida o esquema, os dados e as consultas do projeto sem dependencias externas."""

from pathlib import Path
import sqlite3


ROOT = Path(__file__).resolve().parents[1]
SQL_PATH = ROOT / "sql" / "patas_na_rua.sql"
TABLES = (
    "especie",
    "raca",
    "voluntario",
    "animal",
    "veterinario",
    "tratamento",
    "adotante",
    "adocao",
    "doador",
    "doacao",
)


def portable_setup(sql: str) -> str:
    start = sql.index("CREATE TABLE especie")
    end = sql.index("-- 3. CONSULTAS SELECT")
    return sql[start:end].replace(
        "INT AUTO_INCREMENT PRIMARY KEY", "INTEGER PRIMARY KEY"
    )


def main() -> None:
    sql = SQL_PATH.read_text(encoding="utf-8")
    connection = sqlite3.connect(":memory:")
    connection.execute("PRAGMA foreign_keys = ON")
    connection.executescript(portable_setup(sql))

    counts = {
        table: connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        for table in TABLES
    }
    assert all(count >= 5 for count in counts.values()), counts

    by_species = connection.execute(
        """
        SELECT e.nome, COUNT(a.id_animal)
        FROM especie AS e
        LEFT JOIN animal AS a ON a.id_especie = e.id_especie
        GROUP BY e.id_especie, e.nome
        ORDER BY COUNT(a.id_animal) DESC, e.nome
        """
    ).fetchall()
    assert by_species == [
        ("Cao", 4),
        ("Gato", 4),
        ("Ave", 1),
        ("Coelho", 1),
        ("Outro", 0),
    ], by_species

    treatment_totals = connection.execute(
        """
        SELECT a.nome, v.nome, COUNT(t.id_tratamento), SUM(t.valor)
        FROM tratamento AS t
        JOIN animal AS a ON a.id_animal = t.id_animal
        JOIN veterinario AS v ON v.id_veterinario = t.id_veterinario
        GROUP BY a.id_animal, a.nome, v.id_veterinario, v.nome
        ORDER BY SUM(t.valor) DESC, a.nome
        """
    ).fetchall()
    assert treatment_totals[0] == ("Thor", "Rafael Nunes", 2, 630), treatment_totals

    above_average = connection.execute(
        """
        SELECT a.nome,
               (SELECT SUM(t.valor) FROM tratamento t
                 WHERE t.id_animal = a.id_animal) AS total
        FROM animal a
        WHERE (SELECT COALESCE(SUM(t.valor), 0) FROM tratamento t
                WHERE t.id_animal = a.id_animal) >
              (SELECT AVG(total_animal)
                 FROM (SELECT SUM(valor) AS total_animal
                         FROM tratamento GROUP BY id_animal) totais)
        ORDER BY total DESC
        """
    ).fetchall()
    assert [row[0] for row in above_average] == [
        "Thor",
        "Mel",
        "Frida",
        "Sol",
        "Bob",
    ], above_average

    connection.execute(
        "UPDATE voluntario SET funcao = ? WHERE id_voluntario = 1",
        ("Coordenacao de resgates",),
    )
    assert connection.execute(
        "SELECT funcao FROM voluntario WHERE id_voluntario = 1"
    ).fetchone()[0] == "Coordenacao de resgates"

    connection.execute(
        "DELETE FROM doacao WHERE id_doacao = 9 AND situacao = 'CANCELADA'"
    )
    assert connection.execute("SELECT COUNT(*) FROM doacao").fetchone()[0] == 8

    assert "CREATE PROCEDURE sp_concluir_adocao" in sql
    assert "SIGNAL SQLSTATE '45000'" in sql
    print("Validacao concluida:", counts)
    print("Consultas, UPDATE, DELETE e estrutura da procedure: OK")


if __name__ == "__main__":
    main()
