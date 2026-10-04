/*
================================================================================
 04_results_analysis.sql
 BANK TRANSACTIONS SQL PORTFOLIO PROJECT (ORACLE SQL)

 Bu fayl: 03_tasks_and_solutions.sql-dəki sorğuların nəticələrinə əsaslanan
 YEKUN ANALİZ hissəsidir. GitHub README/portfolio üçün istifadə oluna bilər.
 Aşağıdakı rəqəmlər datasetin real icrasından götürülüb (2024-01 — 2024-06).
================================================================================


1) ÜMUMİ MƏNZƏRƏ
   - 6 filial, 30 müştəri, 764 tranzaksiya (6 aylıq dövr: 2024-01 — 2024-06)
   - Orta tranzaksiya məbləği: ~315 (vahid)
   - 28 müştəri aktivdir, 2 müştərinin (Kenan İbrahimov, Ulviyya Həsənova)
     heç bir tranzaksiyası yoxdur — LEFT JOIN ilə aşkarlanan "qeyri-aktiv
     müştəri" seqmenti.

2) ƏN YÜKSƏK DÖVRİYYƏLİ MÜŞTƏRİLƏR (TASK E2, RANK/DENSE_RANK)
   TOP 5 (ümumi abs. dövriyyəyə görə):
     1. Farid Nağıyev       ~20,798
     2. İlkin Məmmədov      ~20,532
     3. Sevinc Rüstəmova    ~20,492
     4. Vüsal Süleymanov    ~19,387
     5. Cala Vəliyeva       ~19,251
   Bu müştərilər bankın "premium/yüksək aktivlik" seqmenti kimi
   qiymətləndirilə bilər (TASK E6-dakı NTILE kvartil bölgüsündə də 1-ci
   kvartilə düşürlər).

3) NET CASH-FLOW LİDERLƏRİ (TASK D2)
   Ən yüksək müsbət net balans:
     1. İlkin Məmmədov   ~+15,051
     2. Cala Vəliyeva    ~+14,061
     3. Sevinc Rüstəmova ~+12,822
     4. Vüsal Süleymanov ~+11,520
     5. Fuad Cəfərov     ~+11,442
   Bu qrup üçün əmanət və investisiya məhsulları təklif etmək məntiqlidir,
   çünki gəlirləri xərclərindən davamlı şəkildə üstündür.

4) FİLİAL PERFORMANSI (TASK C3, LEFT JOIN + aggregation)
   Tranzaksiya sayına görə:
     1. Mingəçevir Filialı     — 157 tranzaksiya, ümumi dövriyyə ~70,418
     2. Nizami Filialı         — 145 tranzaksiya, ümumi dövriyyə ~23,502
     3. Gənclik Filialı        — 129 tranzaksiya, ümumi dövriyyə ~38,459
     4. Gəncə Mərkəz Filialı   — 113 tranzaksiya, ümumi dövriyyə ~35,422
     5. Yasamal Filialı        — 111 tranzaksiya, ümumi dövriyyə ~31,411
     6. Sumqayıt Filialı       — 109 tranzaksiya, ümumi dövriyyə ~41,411
   Maraqlı müşahidə: Mingəçevir Filialı ən az tranzaksiya sayına baxmayaraq
   (ilkin gözləntinin əksinə) ən yüksək ümumi dövriyyəyə malikdir — bu,
   həmin filialdan keçən orta tranzaksiya məbləğinin digərlərindən əhəmiyyətli
   dərəcədə yüksək olduğunu göstərir və əlavə araşdırma tələb edir.

5) XƏRC KATEQORİYALARI ÜZRƏ BÖLGÜ (TASK D3 əsaslı)
   Ən çox xərclənən kateqoriyalar (ümumi məbləğ üzrə):
     1. RENT (kirayə)          — ~25,052  (43 əməliyyat)
     2. TRANSFER_OUT           — ~16,076  (57 əməliyyat)
     3. LOAN_PAYMENT (kredit)  — ~12,609  (36 əməliyyat)
     4. ATM                    — ~11,232  (55 əməliyyat)
     5. FAMILY_SUPPORT         — ~11,229  (64 əməliyyat)
   Kirayə xərci həm ən yüksək ümumi məbləğə, həm də nisbətən yüksək orta
   əməliyyat dəyərinə malikdir — bu, sabit/məcburi xərclərin müştəri
   büdcəsində üstünlük təşkil etdiyini göstərir.

6) MAAŞ TRENDİ (TASK E3, LAG əsaslı aylıq müqayisə)
   Bütün müştərilər üzrə cəmi ödənilən aylıq maaş:
     2024-01: ~53,058   2024-02: ~50,755   2024-03: ~52,102
     2024-04: ~54,121   2024-05: ~53,883   2024-06: ~58,657
   Fevral ayında qısamüddətli azalma (~-4.3%) müşahidə olunur, lakin
   sonrakı aylarda davamlı artım trendi var — iyun ayı 6 aylıq ən yüksək
   göstəricidir (~+10.6% yanvara nisbətən).

7) ÜMUMİ NƏTİCƏ
   Dataset müştəri seqmentasiyası (aktiv/qeyri-aktiv, yüksək/aşağı dövriyyə,
   NTILE kvartilləri), filial performans müqayisəsi, kateqoriya üzrə xərc
   strukturu və zaman üzrə trend analizi (aylıq maaş dəyişikliyi, əməliyyatlar
   arası fasilə) üçün kifayət qədər zəngin strukturdur. Layihə SQL-in əsas
   alətlərini — single-row functions, INNER/LEFT JOIN, CTE (WITH) və window
   functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE) — real bank
   ssenarisi üzərində, 700+ sətirlik datasetlə nümayiş etdirir.
================================================================================
*/
