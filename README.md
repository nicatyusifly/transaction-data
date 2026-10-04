# Bank Transactions SQL Portfolio (Oracle SQL)

Orta səviyyəli, portfolio üçün hazırlanmış Oracle SQL layihəsi. Bank tranzaksiya
datası üzərində **single-row functions**, **INNER/LEFT JOIN**, **CTE (WITH)** və
**window functions** (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `NTILE`)
nümunələri ilə tapşırıqlar və hazır həllər.

## Data həcmi
- 6 filial (`branches`)
- 30 müştəri (`customers`) — 2-si tranzaksiyasız (LEFT JOIN nümunəsi üçün)
- ~764 tranzaksiya (`transactions`), 2024-01-01 — 2024-06-30 aralığı

## Fayl strukturu (icra sırası)

| Fayl | Təyinat |
|---|---|
| `01_schema.sql` | Cədvəllərin yaradılması (DDL): `branches`, `customers`, `transactions` |
| `02_seed_data.sql` | Test datasının yüklənməsi (DML) |
| `03_tasks_and_solutions.sql` | 5 bölmə üzrə tapşırıqlar və hazır həllər (single-row functions, INNER JOIN, LEFT JOIN, CTE, Window Functions) |
| `04_results_analysis.sql` | Sorğu nəticələrinə əsaslanan yekun analiz (komment şəklində) |

## İşə salma
Fayllar ardıcıl icra olunmalıdır (Oracle SQL uyğun mühitlərdə, məs. Oracle Live SQL,
Oracle SQL Developer və ya oxşar onlayn Oracle sandboxlarında):

```sql
@01_schema.sql
@02_seed_data.sql
@03_tasks_and_solutions.sql
```

`04_results_analysis.sql` icra tələb etmir — yalnız komment şəklində yazılmış
yekun analizdir, README kimi oxuna bilər.

## Mövzular
- **Single-row functions:** `UPPER`, `LOWER`, `SUBSTR`, `INSTR`, `TO_CHAR`,
  `NVL`, `INITCAP`, `MONTHS_BETWEEN`, `TRUNC`, `EXTRACT`
- **JOIN:** `INNER JOIN`, `LEFT JOIN`, çox-cədvəlli aqreqasiya
- **CTE:** çoxmərhələli `WITH` sorğuları (aylıq analiz, gəlir/xərc ayrımı)
- **Window Functions:** `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`,
  `NTILE`, running total (`SUM() OVER`)
