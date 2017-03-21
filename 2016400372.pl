/*
* March 2017
* Implemented by Mehmet Sefa Balik for the Bogazici University CMPE260 course project. All the codes are implemented by me,
* there are no copy-paste or stolen codes here, all the implementation is based on the knowledge that I obtained in the lab section
* and on the internet. Thanks to Professor Albert Ali Salah and assistant Mert Tiftikci for intoducing me with such an excellent
* programming language.
*/

clear_knowledge_base:-    %predicate that clears knowledgebase
  write('predicates that you want to clear must be declared dynamic in the knowledgebase!'),nl,
  count_student_predicate(StudentPredicate),    %counts the number of student/2 predicates in the knowledge base
  count_slot_predicate(SlotPredicate),    %counts the number of available_slots/1 predicates in the knowledge base
  count_rooms(RoomPredicate),   %counts the number of room_capacity/2 predicates in the knowledge base
  retractall(student(_,_)),   %clears all student/2 predicates in the knowledge base
  retractall(available_slots(_)),   %clears all available_slots/1 predicates in the knowledge base
  retractall(room_capacity(_,_)),   %clears all room_capacity/2 predicates in the knowledge base
  write('Knowledge Base Cleared:'),nl,    %following write predicates inform the user what has been cleared from the knowledge base
  write('student/2    '),write(StudentPredicate),nl,
  write('available_slots/1    '),write(SlotPredicate),nl,
  write('room_capacity/2    '),write(RoomPredicate),nl,
  write('').

count_student_predicate(Count):-    %counts the number of student/2 predicates in the knowledge base
  findall(X, student(X,_), List),
  length(List,Count).

count_slot_predicate(Count):-   %counts the number of available_slots/1 predicates in the knowledge base
  findall(X, available_slots(X), List),
  length(List,Count).

count_rooms(Count):-    %counts the number of room_capacity/2 predicates in the knowledge base
  findall(X, room_capacity(X,_), List),
  length(List,Count).

all_students(StudentList):-   %produces the list of all students in the knowledge base
  findall(X,student(X,_),StudentList).

all_courses(Sorted):-   %produces the list of all unique courses in the knowledgebase
  setof(X,Y^student(Y,X),CourseList),   %CourseList holds all the courses that students take
  flatten(CourseList, Flattened),   %flattens the CourseList
  sort(Flattened, Sorted).    %not only sorts the Flattened list but also retracts the repeated courses from the list, So Sorted list holds only unique courses

student_count(SearchCourse, FoundCounter):-   %gives the number of students who takes a particular course
  setof(X,Y^student(Y,X),CourseList),   %CourseList holds the list of all courses that students take
  flatten(CourseList, Flattened),   %Flattened holds the flattened version of the CourseList
  count(Flattened, SearchCourse, FoundCounter),!.   %FoundCounter holds the integer number that means the number of SearchCourse in the Flattened. Cut is used to unsatisfy recursion

count([],_,0).    %base predicate
count([SearchCourse|T],SearchCourse,FoundCounter):- count(T,SearchCourse,Z), succ(Z, FoundCounter).   %recursive, if SearchCourse is in the list FoundCounter is 1+Z.
count([X1|T],SearchCourse,Z):- dif(X1, SearchCourse),count(T,SearchCourse,Z).   %in the case of X1\=SearchCourse, continue recursion

common_students(CourseID1, CourseID2, Count):-    %predicate that counts the number of students who takes two same classes
  all_students(Students),   %Students holds the list of all students in the knowledge base
  takes_course(Count, CourseID1, CourseID2, Students),!.    %worker predicate that takes the course names(CourseID1 and CourseID2), the list that has the list of students(Students), and matches the Count

takes_course(0, _, _, []).    %base predicate
takes_course(Count, CourseID1, CourseID2, [Head|Tail]):-     %worker predicate that takes the course names(CourseID1 and CourseID2), the list that has the list of students(Students), and matches the Count
  student_member(CourseID1, CourseID2, Head),    %worker predicate that checks if the student is member of both classes
  takes_course(StudentC, CourseID1, CourseID2, Tail), succ(StudentC, Count).   %recursion and increment
takes_course(StudentC, CourseID1, CourseID2, [Head|Tail]):-   %in the case of student is not member of both classes, so the count wont be incremented
  not_student_member(CourseID1, CourseID2, Head),   %worker predicate that checks if the student is not member of both classes
  takes_course(StudentC,CourseID1, CourseID2, Tail).    %recursion

student_member(CourseID1, CourseID2, Head):-    %worker predicate that checks if the student is member of both classes
  student(Head, CourseList),    %CourseList holds the list of classes that student takes
  member(CourseID1, CourseList),    %CourseID1 shall be a member of CourseList
  member(CourseID2, CourseList).    %CourseID2 shall be also a member of CourseList

not_student_member(CourseID1, CourseID2, Head):-    %worker predicate that checks if the student is not member of both classes
  student(Head, CourseList),    %CourseList holds the list of classes that student takes
  not(member(CourseID1, CourseList));   %in this case, CourseID1 is not a member of CourseList OR
  student(Head, CourseList),    %used this predicate again because I used OR beforehand, CourseList must be declared after the OR
  not(member(CourseID2, CourseList)).   %in this case again, CourseID1 is not a member of CourseList

final_plan(FinalTail):-   %predicate that calculates final exam time and locations without any conflicts
  all_courses(AllCourses),    %AllCourses holds the list of all courses that students take
  bagof(Y,X^room_capacity(Y,X),RoomName),   %RoomName holds the list of all room names
  available_slots(AvailableSlots),    %AvailableSlots holds the list of all available slots
  arrange_final( FinalTail, AllCourses, RoomName, AvailableSlots).    %arrange_final is a worker predicate that arranges final plan

arrange_final([],[],_,_).   %base predicate
arrange_final([],_,_,[]).   %base predicate
arrange_final([FinalHead|FinalTail],[CourseName1H|CourseName1T], RoomName, [Slot1H|Slot1T]):-   %worker predicate that arranges the final plan
  student_count(CourseName1H, StudentCount),    %StudentCount holds the number of students for a given class
  pick_room(RoomName, StudentCount, MyRoom),    %pick_room is a worker predicate that picks the available room, MyRoom holds the available room
  FinalHead = [CourseName1H, MyRoom, Slot1H],   %FinalHead holds data of an exam
  arrange_final(FinalTail,CourseName1T, RoomName, Slot1T).    %recursion for arranging all the exams

pick_room(RoomName, StudentCount, MyRoom):-    %pick_room is a worker predicate that picks the available room, MyRoom holds the available room
  member(MyRoom,RoomName),    %RoomName is the list of all available rooms and available room (MyRoom) shall be a member of RoomName
  room_capacity(MyRoom, RoomCapacity),    %RoomCapacity holds the capacity of MyRoom
  StudentCount =< RoomCapacity.   %StudentCount is the number of students that takes a class and RoomCapacity shall be greater or equal than StudentCount

errors_for_plan(Final, Error):-   %predicate that find errors in a Final plan, and report their error Count
  errors_for_capacity(Final, ErrorCapacity),    %worker predicate that handles the errors for the over capacity condition
  ErrorC is ErrorCapacity,    %ErrorC holds the errors for the capacity
  errors_for_slots(Final, ErrorSlot),   %worker predicate that handles the errors for the slots
  Error is ErrorC + ErrorSlot,!.    %Error holds the final error, cut is used not to satisfy again

errors_for_slots(Final,Errors):-    %worker predicate that handles the errors for the slots
    arrange_slot_room(Final, Slots, Courses),   %worker predicate that scans the slots and courses in the given final plan
    duplicate_slots(Slots,Slots,Courses,Error),   %worker predicate that examines the slots and courses that is scanned by arrange_slot_room predicate, and finds the errors
    Errors is Error.    %assignment added this way to prevent returning in the form of 3+0+0 errors

duplicate_slots(_,[],_,0).    %base predicate
duplicate_slots(Slots,[HS|TS],Courses,Error) :-not(member(HS,TS)), duplicate_slots(Slots,TS,Courses,Error).   %HS (HeadSlot) is not a member of TS (TailSlot). so continue recursion
duplicate_slots(Slots,[HS|TS],Courses,ErrorCountA+ErrorCountB) :-   %predicate that detects the duplicate slots and counts the errors
  member(HS, TS),   %HeadSlot is a member of TailSlot
  nth0(IS,Slots,HS),    %determines the index of duplicated slot in the Slots list
  nth0(IS,Courses,DupCourse1),    %determines the first duplicated course
  nth0(IS,Slots,_,RemainderSlots),    %RemainderSlots holds the remaining slots from duplication
  nth1(IS2,RemainderSlots,HS),    %determines the index of second duplicated slot
  nth0(IS2,Courses,DupCourse2),   %determines the second duplicated course based on the index of it that is found previously
  common_students(DupCourse1,DupCourse2,ErrorCountA),   %ErrorCountA holds the number of students that takes both duplicated classes
  duplicate_slots(Slots,TS,Courses,ErrorCountB).    %recursion

arrange_slot_room([],[],[]).    %base predicate
arrange_slot_room([[Course, _, Slot]|FinalTail], [SlotsHead|SlotsTail], [CoursesHead|CoursesTail]):-    %predicate that scans the slots and courses in the given final plan
  SlotsHead = Slot,
  CoursesHead = Course,
  arrange_slot_room(FinalTail,SlotsTail,CoursesTail).   %recursion

errors_for_capacity([],0).    %base predicate
errors_for_capacity([[Course, Room, _]|FinalTail], ErrorCount+ErrorCountNew):-    %predicate that finds the errors for the capacity constraints
  errors_for_capacity(FinalTail, ErrorCount),   %recursion
  is_capacity_available(Course, Room, ErrorCountNew).   %determines if the capacity is available or not

is_capacity_available(Course, Room, ErrorCount):-   %predicate that determines if the capacity is available or not
  room_capacity(Room, RoomCapacity),    %RoomCapacity holds the capacity
  student_count(Course, StudentCount),    %StudentCount holds the number of students that takes Course
  (StudentCount > RoomCapacity ->   %StudentCount must be greater than RoomCapacity
  ErrorCount is StudentCount - RoomCapacity; ErrorCount is 0).    %if StudentCount is greater than RoomCapacity than ErrorCount must be StudentCount - RoomCapacity, else ErrorCount is 0
