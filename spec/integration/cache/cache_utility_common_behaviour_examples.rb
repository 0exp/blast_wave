# frozen_string_literal: true

shared_examples 'Cache utility => Common behaviour' do
  after { cache_storage.clear }

  describe '#increment' do
    let(:expiration_time) { 8 } # NOTE: in seconds
    let(:entry) { { key: SecureRandom.hex, value: 1 } }

    shared_examples 'incrementation' do
      specify 'by default: decrements by 1' do
        new_amount = cache_storage.increment(entry[:key])
        expect(new_amount).to eq(2)

        new_amount = cache_storage.increment(entry[:key])
        expect(new_amount).to eq(3)

        new_amount = cache_storage.increment(entry[:key])
        expect(new_amount).to eq(4)
      end

      specify 'returns new amount' do
        new_amount = cache_storage.increment(entry[:key], 1)
        expect(new_amount).to eq(2)

        new_amount = cache_storage.increment(entry[:key], 3)
        expect(new_amount).to eq(5)

        new_amount = cache_storage.increment(entry[:key], 2)
        expect(new_amount).to eq(7)
      end
    end

    context 'with previously defined temporal entry' do
      before { cache_storage.write(entry[:key], entry[:value], expires_in: expiration_time) }

      it_behaves_like 'incrementation'

      context 'with re-expiration' do
        specify 'entry gets new expiration time' do
          cache_storage.increment(entry[:key], expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds, current value: 2

          cache_storage.increment(entry[:key], 2, expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds again, current value: 4

          expect(cache_storage.read(entry[:key]).to_i).to eq(4)
          sleep(5) # NOTE: remaining time: -1 seconds

          expect(cache_storage.read(entry[:key])).to eq(nil)
        end
      end

      context 'without re-expiration' do
        specify 'entry dies when expiration time coming; creates new permanent entry' do
          cache_storage.increment(entry[:key], 2)
          sleep(expiration_time + 1) # NOTE: remaining time: -1 seconds, current value: 3

          # NOTE: new amount: 2, old entry is dead, new entry is permanent
          new_amount = cache_storage.increment(entry[:key], 2)
          expect(new_amount).to eq(2)

          sleep(expiration_time + 1) # NOTE: remaining time: -1 esconds, current value: 2
          expect(cache_storage.read(entry[:key]).to_i).to eq(2)
        end
      end
    end

    context 'with previously defined permanent entry' do
      before { cache_storage.write(entry[:key], entry[:value]) }

      it_behaves_like 'incrementation'

      context 'with re-expiration' do
        specify 'entry gets new expiration time' do
          cache_storage.increment(entry[:key], expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds, current value: 2

          cache_storage.increment(entry[:key], 2, expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds again, current value: 4

          expect(cache_storage.read(entry[:key]).to_i).to eq(4)
          sleep(5) # NOTE: remaining time: -1 seconds

          expect(cache_storage.read(entry[:key])).to eq(nil)
        end
      end

      context 'without re-expiration' do
        it 'increases entry value' do
          new_amount = cache_storage.increment(entry[:key])
          expect(new_amount).to eq(2)

          new_amount = cache_storage.increment(entry[:key], 3)
          expect(new_amount).to eq(5)

          sleep(expiration_time + 1)

          new_amount = cache_storage.increment(entry[:key], 5)
          expect(new_amount).to eq(10)
        end
      end
    end

    context 'without previously defined entries' do
      context 'invocation with expiration' do
        it 'creates new temporal entry with corresponding initial value' do
          # NOTE: create new entry with a random initial value
          ini_value = rand(1..100)
          new_amount = cache_storage.increment(entry[:key], ini_value, expires_in: expiration_time)
          expect(new_amount).to eq(ini_value)

          sleep(expiration_time + 1) # NOTE: expire current entry

          # NOTE: create new entry without initial value
          new_amount = cache_storage.increment(entry[:key], expires_in: expiration_time)
          expect(new_amount).to eq(1)
        end
      end

      context 'invocation without expiration' do
        it 'creates new permanent entry with corresponding initial value' do
          ini_value = rand(1..100)
          new_amount = cache_storage.increment(entry[:key], ini_value)
          expect(new_amount).to eq(ini_value)

          sleep(expiration_time + 1) # NOTE: try to expire current entry

          # NOTE: increase entry by default value
          new_amount = cache_storage.increment(entry[:key])
          expect(new_amount).to eq(ini_value + 1)
        end
      end
    end
  end

  describe '#decrement' do
    let(:expiration_time) { 8 } # NOTE: in seconds
    let(:entry) { { key: SecureRandom.hex, value: 1 } }

    shared_examples 'decrementation' do
      specify 'by default: increments by 1' do
        new_amount = cache_storage.decrement(entry[:key])
        expect(new_amount).to eq(0)

        new_amount = cache_storage.decrement(entry[:key])
        expect(new_amount).to eq(-1) | eq(0)

        new_amount = cache_storage.decrement(entry[:key])
        expect(new_amount).to eq(-2) | eq(0)
      end

      specify 'returns new amount' do
        new_amount = cache_storage.decrement(entry[:key], 1)
        expect(new_amount).to eq(0)

        new_amount = cache_storage.decrement(entry[:key], 3)
        expect(new_amount).to eq(-3) | eq(0)

        new_amount = cache_storage.decrement(entry[:key], 2)
        expect(new_amount).to eq(-5) | eq(0)
      end
    end

    context 'with previously defined temporal entry' do
      before { cache_storage.write(entry[:key], entry[:value], expires_in: expiration_time) }

      it_behaves_like 'decrementation'

      context 'with re-expiration' do
        specify 'entry gets new expiration time' do
          cache_storage.decrement(entry[:key], expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds, current value: 0

          cache_storage.decrement(entry[:key], 2, expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds again, current value: -2

          expect(cache_storage.read(entry[:key]).to_i).to eq(-2) | eq(0)
          sleep(5) # NOTE: remaining time: -1 seconds

          expect(cache_storage.read(entry[:key])).to eq(nil)
        end
      end

      context 'without re-expiration' do
        specify 'entry dies when expiration time coming; creates new permanent entry' do
          cache_storage.decrement(entry[:key], 2)
          sleep(expiration_time) # NOTE: remaining time: 0 seconds, old value: -1; new: nothing

          new_amount = cache_storage.decrement(entry[:key], 2)
          # NOTE: new amount: -2, old entry is dead, new entry is permanent
          expect(new_amount).to eq(-2) | eq(0)
          sleep(expiration_time) # NOTE: remaining time: 0 esconds, current value: -2
          expect(cache_storage.read(entry[:key]).to_i).to eq(-2) | eq(0)
        end
      end
    end

    context 'with previously defined permanent entry' do
      before { cache_storage.write(entry[:key], entry[:value]) }

      it_behaves_like 'decrementation'

      context 'with re-expiration' do
        specify 'entry gets new expiration time' do
          cache_storage.decrement(entry[:key], expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds, current value: 0

          cache_storage.decrement(entry[:key], 2, expires_in: expiration_time)
          sleep(4) # NOTE: remaining time: 4 seconds again, current value: -2

          expect(cache_storage.read(entry[:key]).to_i).to eq(-2) | eq(0)
          sleep(5) # NOTE: remaining time: -1 seconds

          expect(cache_storage.read(entry[:key])).to eq(nil)
        end
      end

      context 'without re-expiration' do
        it 'increases entry value' do
          new_amount = cache_storage.decrement(entry[:key])
          expect(new_amount).to eq(0)

          new_amount = cache_storage.decrement(entry[:key], 3)
          expect(new_amount).to eq(-3) | eq(0)

          sleep(expiration_time)

          new_amount = cache_storage.decrement(entry[:key], 5)
          expect(new_amount).to eq(-8) | eq(0)
        end
      end
    end

    context 'without previously defined entries' do
      context 'invocation with expiration' do
        it 'creates new temporal entry with corresponding initial value' do
          # NOTE: create new entry with a random initial value
          ini_value = rand(1..100)
          new_amount = cache_storage.decrement(entry[:key], ini_value, expires_in: expiration_time)
          expect(new_amount).to eq(-ini_value) | eq(0)

          sleep(expiration_time) # NOTE: expire current entry

          # NOTE: create new entry without initial value
          new_amount = cache_storage.decrement(entry[:key], expires_in: expiration_time)
          expect(new_amount).to eq(-1) | eq(0)
        end
      end

      context 'invocation without expiration' do
        it 'creates new permanent entry with corresponding initial value' do
          ini_value = rand(1..100)
          new_amount = cache_storage.decrement(entry[:key], ini_value)
          expect(new_amount).to eq(-ini_value) | eq(0)

          sleep(expiration_time) # NOTE: try to expire current entry

          # NOTE: increase entry by default value
          new_amount = cache_storage.decrement(entry[:key])
          expect(new_amount).to eq(-ini_value - 1) | eq(0)
        end
      end
    end
  end

  describe '#read' do
    context 'when the required entry exists' do
      let(:expiration_time) { 8 } # NOTE: in seconds
      let(:entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

      context 'and entiry without expiration' do
        before { cache_storage.write(entry[:key], entry[:value]) }

        it 'returns entry value: exists => entry value; doesnt exist => nil' do
          expect(cache_storage.read(entry[:key])).to eq(entry[:value])
          sleep(expiration_time + 1) # NOTE: remaining time: -1 seconds
          expect(cache_storage.read(entry[:key])).to eq(entry[:value])
        end
      end

      context 'and entry with expiration' do
        before { cache_storage.write(entry[:key], entry[:value], expires_in: expiration_time) }

        it 'returns corresponding value: alive => entry value, expired => nil' do
          expect(cache_storage.read(entry[:key])).to eq(entry[:value])
          sleep(expiration_time + 1) # NOTE: remaining time: -1 seconds
          expect(cache_storage.read(entry[:key])).to eq(nil)
        end
      end
    end

    context 'when the required entry doesnt exist' do
      let(:nonexistent_entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

      it 'returns nil' do
        expect(cache_storage.read(nonexistent_entry[:key])).to eq(nil)
      end
    end
  end

  describe '#write' do
    let!(:expiration_time) { 8 } # NOTE: in seconds
    let!(:first_pair)      { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
    let!(:second_pair)     { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

    context 'with expiration' do
      it 'writes permanent entry' do
        # NOTE: permanent entries
        cache_storage.write(first_pair[:key], first_pair[:value])
        cache_storage.write(second_pair[:key], second_pair[:value])

        expect(cache_storage.read(first_pair[:key])).to eq(first_pair[:value])
        expect(cache_storage.read(second_pair[:key])).to eq(second_pair[:value])

        sleep(expiration_time) # NOTE: remaining time: 0 seconds

        # NOTE: all entries alive
        expect(cache_storage.read(first_pair[:key])).to eq(first_pair[:value])
        expect(cache_storage.read(second_pair[:key])).to eq(second_pair[:value])
      end
    end

    context 'without expiration' do
      it 'writes temporal entry' do
        # NOTE: temporal entry
        cache_storage.write(first_pair[:key], first_pair[:value], expires_in: expiration_time)

        # NOTE: permanent entry
        cache_storage.write(second_pair[:key], second_pair[:value])

        expect(cache_storage.read(first_pair[:key])).to eq(first_pair[:value])
        expect(cache_storage.read(second_pair[:key])).to eq(second_pair[:value])

        sleep(expiration_time + 1)

        # NOTE: temporal entry is dead
        expect(cache_storage.read(first_pair[:key])).to eq(nil)
        # NOTE: permanent entry is alive
        expect(cache_storage.read(second_pair[:key])).to eq(second_pair[:value])
      end
    end
  end

  describe '#delete' do
    it 'removes entry from cache' do
      first_pair  = { key: SecureRandom.hex, value: SecureRandom.hex(4) }
      second_pair = { key: SecureRandom.hex, value: SecureRandom.hex(4) }

      cache_storage.write(first_pair[:key], first_pair[:value])
      cache_storage.write(second_pair[:key], second_pair[:value])

      cache_storage.delete(first_pair[:key])
      expect(cache_storage.read(first_pair[:key])).to eq(nil)
      expect(cache_storage.read(second_pair[:key])).to eq(second_pair[:value])

      cache_storage.delete(second_pair[:key])
      expect(cache_storage.read(second_pair[:key])).to eq(nil)
      expect(cache_storage.read(second_pair[:key])).to eq(nil)
    end
  end

  describe '#re_expire' do
    it 'changes expiration time of entry' do
      pair = { key: SecureRandom.hex, value: SecureRandom.hex(4) }

      # NOTE: remaining time: 8 seconds
      cache_storage.write(pair[:key], pair[:value], expires_in: 8)

      # NOTE: remaining time: 4 seconds
      sleep(4)

      # NOTE: remaining time: 8 seconds again
      cache_storage.re_expire(pair[:key], expires_in: 8)

      # NOTE: remaining time: 4 seconds
      sleep(4)

      # NOTE: record is alive
      expect(cache_storage.read(pair[:key])).to eq(pair[:value])

      # NOTE: remaining time: -1 second
      sleep(5)

      # NOTE: record is dead
      expect(cache_storage.read(pair[:key])).to eq(nil)
    end
  end

  describe '#clear' do
    it 'clears storage' do
      # NOTE: write random values
      value_pairs = Array.new(10) { { key: SecureRandom.hex, value: rand(0..10) } }.tap do |pairs|
        pairs.each { |pair| cache_storage.write(pair[:key], pair[:value]) }
      end

      # NOTE: clear storage
      cache_storage.clear

      # NOTE: check that written values doesnt exist
      value_pairs.each do |pair|
        expect(cache_storage.read(pair[:key])).to eq(nil)
      end
    end
  end
end
