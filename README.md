## Tematyka projektu

Chcieliśmy zrobić system paczkomatowy, ale potem zdecydowaliśmy, że można do tego podłączyć jeszcze kilka sposobów dostawy. To są kuriery i zwykłe placówki. 

W rezultacie otrzymaliśmy coś podobnego do systemu pocztowego.

## Spotkane problemy

Największym problemem byli statusy. Chcieliśmy mieć historię statusów każdej paczki i dla każdego statusu mieć jakąś dodatkową informację (np. jaki kurier dostarczy paczkę). Ale dla każdego statusu ta informacja może być bardzo różnej, dlatego nie chcieliśmy robić jedną tabelę dla informacji o wszystkich statusach. 
W końcu dla każdego statusu zrobiliśmy tabele z dodatkową informacją i tabelę statusy, w którą są wszystkie statusy i nazwy wszystkich tabel z informacją. Zaletami tego rozwiązania są to, że nie trzeba robić jedną tabelę z różną informacją i dużą liczbą NULLów, i to, że łatwiej dodawać nowe statusy. A wadą jest to, że nie jest tak łatwo uzyskać dostęp do każdej tabeli z informacją.

Oczywiście ma nasz system możliwość rejestracji konta. Ale wtedy powstaje jeszcze jeden problem. Chcielibyśmy mieć możliwość wysyłać paczki do niezarejestrowanych użytkowników. Zrobiliśmy tak, że gdy ktoś chce wysłać paczkę do niezarejestrowanego użytkownika, to rejestrujemy ostatniego bez logina i hasła. Jeśli później sam tworzy konto, to zmieniamy ten flag na zmieniamy mu login i hasło na podane. 

Też pozostał u nas problem, że możemy przewozić paczki pomiędzy różnymi typami miejsc (placówki, paczkomaty, magazyny, i od razu do osoby), dlatego w tabeli **status_info_transit** są kolumne *type_from* i *type_where* przechowujące typy miejsc do z których i do których wieziemy. Też z tego powodu tablica **status_info_transit** jest związana z **storages**, **places** i **cells**.

## Krótki opis tabelek

**parcels**: jest to główna tabela, w niej znajduje się informacja o wszystkich paczkach. Skąd i kto go wysyłał, dokąd i do kogo go wysyłali, rozmiar paczki.

Grupa **Status**: jest to grupa tabel, które przechowują informację o statusach i ich zmianach. Mamy 5 typów
statusów: *registrated* (paczka była zarejestrowana lub przez internet, lub w placówki), *given* (paczka była nadana do placówki lub do paczkomatu), *transit* (paczka jest w drodze), *storage* (paczka znajduje się w magazynie i czeka na następny transit), *delivered* (paczka już dojechała do adresaty, i on jej zabrał lub ona leży w jego skrzynce pocztowej). To jest odpowiednio tabelom **status_info**. Tę tabeli są związane z tabelą **parcels** przez **parcel_history**. Też mamy tabel **statuses**, która przechowuje informację o typach statusów.

Grupa **Couriers**: **couriers** --- przechowuje dane osobowe kurierach, też datę s której pracuje, do której pracował, pensję za godzinę. **couriers_schedule** --- wyznacza dla każdego kuriera, w który dzień tygodnia on pracuje i kilka czasu. **couriers_trucks** - ma informacje, o transporty, którym korzystają kuriery (założyliśmy, że w ogóle korzystają z ciężarówek).

Grupa **User**: przechowuje informację o wszystkich użytkownikach, które wysyłają lub dostają paczkę. Mamy informację osobistą o każdym użytkowniku w tabeli **users** (oprócz wszystkich ograniczeń które, są widoczne na schemacie, użytkownik musi podać lub numer, lub email). W tabeli **user_addresses** mamy dla każdego użytkownika wszystkie go adresy (może ich być więcej niż jeden).

Grupa **WhereCanGo**: Przechowuje informację o miejscach, gdzie możemy wysyłać lub odebrać paczki (placówki — tablica **places**, paczkomaty — tablica **parcel_lockers**), gdzie są przechowywany paczki (magazyny — tablica **storages**). Też dla każdego paczkomatu mamy tablicę wszystkich komórek - **cells**, przechowujące ich rozmiar.
Oprócz tego mamy dla każdej placówki i dnia tygodnia, czas pracy w tabeli **places_schedule**, podobny do czasu pracy kurierów. 

## Aplikacja
Jeszcze mamy aplikację dla użytkowników. Można w niej się zarejestrować, a potem wejść do serwisu. Tam można sprawdzać status swoich paczek i dodawać nowe. Jeszcze można zmieniać ustawienia (hasło, numer telefonu, email, adresy, login, imię i nazwisko). Dane wprowadzone przez użytkowników są sprawdzane.

Żeby skorzystać z aplikacji prawdopodobnie trzeba mieć zainstalowane qt5 i pqxx. Następnie w folderze src trzeba wykonać dwa polecenia: qmake, a potem make. Żeby dołączyć do swojej bazy danych, trzeba zedytować plik ppl.conf, i uruchomić plik ppl.

---


                                                     Autory: Mikalai Navitski, Leonid Dorochko
