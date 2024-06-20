-- subject change request problem

CREATE DATABASE subject_change;

-- Create SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(50) NOT NULL,
    SubjectID VARCHAR(50) NOT NULL,
    Is_Valid BIT NOT NULL,
    PRIMARY KEY (StudentID, SubjectID)
);

-- Create SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentID VARCHAR(50) NOT NULL,
    SubjectID VARCHAR(50) NOT NULL,
    PRIMARY KEY (StudentID, SubjectID)
);

-- Insert initial records into SubjectAllotments table
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103036', 'PO1491', 1);
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103036', 'PO1492', 0);
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103036', 'PO1493', 0);
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103036', 'PO1494', 0);
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES ('159103036', 'PO1495', 0);

-- Insert a record into SubjectRequest table
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES ('159103036', 'PO1496');

-- Verify records in SubjectAllotments table
SELECT * FROM SubjectAllotments;

-- Verify records in SubjectRequest table
SELECT * FROM SubjectRequest;


CREATE PROCEDURE usp_UpdateSubjectAllotment
AS
BEGIN
    -- Declare necessary variables
    DECLARE @StudentID VARCHAR(50);
    DECLARE @RequestedSubjectID VARCHAR(50);
    DECLARE @CurrentSubjectID VARCHAR(50);
    
    -- Create a cursor to iterate through each record in SubjectRequest
    DECLARE subject_cursor CURSOR FOR
    SELECT StudentId, SubjectId
    FROM SubjectRequest;
    
    OPEN subject_cursor;
    FETCH NEXT FROM subject_cursor INTO @StudentID, @RequestedSubjectID;
    
    -- Loop through each subject request
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student has a currently valid subject
        SELECT @CurrentSubjectID = SubjectId
        FROM SubjectAllotments
        WHERE StudentId = @StudentID AND Is_Valid = 1;
        
        -- If there is a valid subject and it is different from the requested subject
        IF @CurrentSubjectID IS NOT NULL AND @CurrentSubjectID <> @RequestedSubjectID
        BEGIN
            -- Invalidate the current subject
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentId = @StudentID AND SubjectId = @CurrentSubjectID;
            
            -- Insert the new requested subject as valid
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END
        -- If there is no valid subject for the student
        ELSE IF @CurrentSubjectID IS NULL
        BEGIN
            -- Insert the new requested subject as valid
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1);
        END
        
        -- Fetch the next record from the cursor
        FETCH NEXT FROM subject_cursor INTO @StudentID, @RequestedSubjectID;
    END
    
    -- Close and deallocate the cursor
    CLOSE subject_cursor;
    DEALLOCATE subject_cursor;
END;


EXEC usp_UpdateSubjectAllotment;