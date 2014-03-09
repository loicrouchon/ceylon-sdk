"A [[Queue]] implemented using a backing [[Array]] where
 the front of the queue is the smallest element of the
 queue according to the order relation defined by [[compare]]
 function and where the back of the queue is the not
 the smallest element.
 Note that this implementation doesn't guarantee the last
 element to be the maximum element of the queue.
 
 The size of the backing `Array` is called the _capacity_
 of the `PriorityQueue`. The capacity of a new instance is 
 specified by the given [[initialCapacity]]. The capacity is 
 increased when [[size]] exceeds the capacity. The new 
 capacity is the product of the current capacity and the 
 given [[growthFactor]]."
by ("Loic Rouchon")
shared class PriorityQueue<Element>(compare, initialCapacity = 0,
            growthFactor=1.5, elements = {})  
        satisfies Collection<Element> & Queue<Element>
        given Element satisfies Object {
    
    "The initial size of the backing array."
    Integer initialCapacity;
    
    "The factor used to determine the new size of the
     backing array when a new backing array is allocated."
    Float growthFactor;
    
    "A comparator function used to sort the elements."
    Comparison compare(Element x, Element y);
    
    "The initial elements of the list."
    {Element*} elements;
    
    function store(Integer capacity) => arrayOfSize<Element?>(capacity, null);
    
    function haveKnownSize({Element*} elements) => elements is Collection<Element>|[Element*];
    
    variable Array<Element?> array;
    variable Integer length;
    
    if (haveKnownSize(elements)) {
        length = elements.size;
        array = store(length > initialCapacity then length else initialCapacity);
    } else {
        length = 0;
        array = store(initialCapacity);
    }
    
    void grow(Integer increment) {
        value neededCapacity = length + increment;
        value maxArraySize = runtime.maxArraySize;
        if (neededCapacity > maxArraySize) {
            throw OverflowException(); //TODO: give it a message!
        }
        if (neededCapacity > array.size) {
            value grownCapacity = (neededCapacity * growthFactor).integer;
            value newCapacity = grownCapacity < neededCapacity || grownCapacity > maxArraySize 
                    then maxArraySize else grownCapacity;
            value grown = store(newCapacity);
            array.copyTo(grown);
            array = grown;
        }
    }
    
    void add(Element element) {
        grow(1);
        array.set(length, element);
        length++;
    }
    
    Integer parent(Integer index) => index / 2;
    Integer leftChild(Integer index) => index * 2;
    Integer rightChild(Integer index) => index * 2 + 1;
    
    Element elt(Integer index) {
        assert(exists element = array[index]);
        return element;
    }
    
    Comparison compareIndexes(Integer first, Integer second) => compare(elt(first), elt(second));
    
    void swap(Integer first, Integer second) {
        value element = array[first];
        array.set(first, array[second]);
        array.set(second, element);
    }
    
    void bubbleUp(Integer index) {
        if (index == 0) {
            return;
        }
        value parentIndex = parent(index);
        if (compareIndexes(index, parentIndex) == smaller) {
            swap(index, parentIndex);
            bubbleUp(parentIndex);
        }
    }
    
    Integer? minChildrenIndex(Integer index) {
        Integer leftChildIndex = leftChild(index);
        if (leftChildIndex >= length) {
            return null;
        }
        Integer rightChildIndex = rightChild(index);
        if (rightChildIndex >= length) {
            return leftChildIndex;
        }
        Comparison comparison = compareIndexes(leftChildIndex, rightChildIndex);
        if (comparison == smaller) {
            return leftChildIndex;
        }
        return rightChildIndex;
    }
    
    void bubbleDown(Integer index) {
        print("bubbleDown index:``index`` = ``array[index] else "<null>"``");
        if (exists childIndex = minChildrenIndex(index),
                compareIndexes(childIndex, index) == smaller) {
            swap(index, childIndex);
            bubbleDown(childIndex);
        }
    }
    
    void addInitialElements() {
        if (haveKnownSize(elements)) {
            variable Integer index = 0;
            for (element in elements) {
                array.set(index++, element);
            }
        } else {
            for (element in elements) {
                add(element);
            }
        }
        if (length > 0) {
            for (index in (length-1)..0) {
                print("=> bubble down for ``index``");
                bubbleDown(index);
            }
            print("=> done");
        }
    }
    addInitialElements();
    
    size => length;
    
    "The smallest element (regarding the order
     relation defined by [[compare]]) of the 
     queue, or `null` if the queue is empty."
    shared actual Element? front => array[0];
    
    "The element currently at the end of the 
     queue, or `null` if the queue is empty.
     This is not necessarily the largest element
     regarding the order relation defined by [[compare]]"
    shared actual Element? last => array[length - 1];
    
    "The element currently at the end of the 
     queue, or `null` if the queue is empty.
     This is not necessarily the largest element
     regarding the order relation defined by [[compare]]"
    shared actual Element? back => last;
    
    "Add a new element to the queue."
    shared actual void offer(Element element) {
        add(element);
        bubbleUp(length - 1);
    }
    
    "Remove and return the smallest element ([[front]] element) from this queue"
    shared actual Element? accept() {
        value element = front; 
        if (length > 0) {
            array.set(0, last);
            array.set(--length, null);
            bubbleDown(0);
        }
        return element;
    }
    
    "An iterator for the elements belonging to this stream.
     Elements returned by this iterator are not ordered"
    shared actual Iterator<Element> iterator() {
        if (length > 0) {
            object it satisfies Iterator<Element> {
                variable Integer index = 0;
                shared actual Element|Finished next() {
                    value element = array[index];
                    if (exists element) {
                        index++;
                        return element;
                    }
                    assert(index == length);
                    return finished;
                }
                
            }
            return it;
        }
        else {
            return emptyIterator;
        }
    }
    
    shared actual Collection<Element> clone() {
        value clone = PriorityQueue {
            compare = compare;
            initialCapacity = length;
            growthFactor = growthFactor;
        };
        clone.length = length;
        clone.array = array.clone();
        return clone;
    }
}